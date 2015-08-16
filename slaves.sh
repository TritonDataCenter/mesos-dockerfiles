#!/bin/bash

# create two slaves in each of multiple data centers
# this parallelizes docker operations in each data center and geographic diversity
#
# this doesn't use Docker Compose because it doesn't seem to work for this case
# or, perhaps it's just me who can't make it work
#
# anyway, I'll take the opportunity to parralelize this with happy ampersands

echo "     project prefix: $1"
echo "       mesos master: $2"
echo "current Docker host: $3"

function start_slave {

    for i in {1..2}
    do
        name="$COMPOSE_PROJECT_NAME"_slave_"$i"
        echo "creating $name on $DOCKER_HOST connected to $MESOS_MASTER"

        docker \
        -H $DOCKER_HOST \
        run \
        -d \
        -p 5051 \
        --name=$name \
        --restart=always \
        -e "TLSCA=`cat "$DOCKER_CERT_PATH"/ca.pem`" \
        -e "TLSCERT=`cat "$DOCKER_CERT_PATH"/cert.pem`" \
        -e "TLSKEY=`cat "$DOCKER_CERT_PATH"/key.pem`" \
        -e "DOCKER_HOST=$DOCKER_HOST" \
        -e "MESOS_MASTER=$MESOS_MASTER" \
        misterbisson/triton-mesos-slave &
    done
}

export COMPOSE_PROJECT_NAME=$1
export MESOS_MASTER=$2
datacenters=( "us-east-3b" "us-east-1" "us-sw-1" "eu-ams-1" )
for i in "${datacenters[@]}"
do

    if [ "tcp://{$2}.docker.joyent.com:2376" = "$i" ]
    then
        continue
    fi

    echo
    echo "Creating slaves in $i"
    export DOCKER_HOST="tcp://$i.docker.joyent.com:2376"
    start_slave
done

export DOCKER_HOST="tcp://{$2}.docker.joyent.com:2376"