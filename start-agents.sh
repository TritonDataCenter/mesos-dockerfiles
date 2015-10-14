#!/bin/bash

# create Mesos agents to connect to multiple Triton data centers
# this adds geographic diversity and redundancy, but adds complexity for everything else
#
# this doesn't use Docker Compose because it doesn't seem to work for this case
# or, perhaps it's just me who can't make it work

COMPOSE_PROJECT_NAME=${1:-${COMPOSE_PROJECT_NAME}}
MESOS_MASTER=${2:-${MESOS_MASTER}}
DOCKER_HOST=${3:-${DOCKER_HOST}}

echo "     project prefix: $COMPOSE_PROJECT_NAME"
echo "       mesos master: $MESOS_MASTER"
echo "current Docker host: $DOCKER_HOST"

function start_agent {

    name="${COMPOSE_PROJECT_NAME}_agent_${AGENT_DC}_${i}"
    link="${COMPOSE_PROJECT_NAME}_zookeeper_1"
    echo "creating $name on $DOCKER_HOST connected to $MESOS_MASTER"

    docker run \
    -d \
    -p 5051 \
    -m 128m \
    --name=$name \
    --restart=always \
    --link "$link":zookeeper \
    -e "TLSCA=`cat ${DOCKER_CERT_PATH}/ca.pem`" \
    -e "TLSCERT=`cat ${DOCKER_CERT_PATH}/cert.pem`" \
    -e "TLSKEY=`cat ${DOCKER_CERT_PATH}/key.pem`" \
    -e "DOCKER_HOST=$AGENT_DOCKER_HOST" \
    -e "MESOS_MASTER=zk://zookeeper:2181/mesos" \
    misterbisson/triton-mesos-agent:2015-07-06-triton-r1 &
}

datacenters=( "us-east-3b" "us-east-1" "us-sw-1" "eu-ams-1" )
for i in "${datacenters[@]}"
do
    # don't create additional hosts for the current data center
    if [ "tcp://$i.docker.joyent.com:2376" == "$DOCKER_HOST" ]
    then
        continue
    fi

    echo
    echo "Creating agent for $i"
    export AGENT_DC=$i
    export AGENT_DOCKER_HOST="tcp://$i.docker.joyent.com:2376"
    start_agent
done
