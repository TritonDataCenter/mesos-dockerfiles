#!/bin/bash

# check for prereqs
command -v docker >/dev/null 2>&1 || { echo "Docker is required, but does not appear to be installed. See https://docs.joyent.com/public-cloud/api-access/docker"; exit; }
command -v sdc-listmachines >/dev/null 2>&1 || { echo "Joyent CloudAPI CLI is required, but does not appear to be installed. See https://apidocs.joyent.com/cloudapi/#getting-started"; exit; }
command -v json >/dev/null 2>&1 || { echo "JSON CLI tool is required, but does not appear to be installed. See https://apidocs.joyent.com/cloudapi/#getting-started"; exit; }

# manually name the project
export COMPOSE_PROJECT_NAME=mesos

# give the docker remote api more time before timeout
export DOCKER_CLIENT_TIMEOUT=300

# the environment variables used to connect to the Triton Docker API
export TLSCA=`cat "$DOCKER_CERT_PATH"/ca.pem`
export TLSCERT=`cat "$DOCKER_CERT_PATH"/cert.pem`
export TLSKEY=`cat "$DOCKER_CERT_PATH"/key.pem`

# the default Mesos master URL
export MESOS_MASTER=master:5050

echo 'Starting Mesos with Marathon'

echo
echo 'Pulling the most recent images'
docker-compose pull

echo
echo 'Starting containers'
docker-compose up -d --no-recreate

 mesos_consul_1

# Wait for Consul
echo
echo 'Waiting for Consul'
export CONSUL="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$COMPOSE_PROJECT_NAME"_consul_1):8500"
ISRESPONSIVE=0
while [ $ISRESPONSIVE != 1 ]; do
    echo -n '.'

    curl -fs --connect-timeout 1 http://$CONSUL/ui &> /dev/null
    if [ $? -ne 0 ]
    then
        sleep .7
    else
        let ISRESPONSIVE=1
    fi
done
echo
echo 'Consul is now running'
echo "Dashboard: $CONSUL/ui/"
command -v open >/dev/null 2>&1 && `open http://$CONSUL/ui/`

# Wait for Mesos master
echo
echo 'Waiting for Mesos master'
export MESOS_MASTER="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$COMPOSE_PROJECT_NAME"_master_1):5050"
ISRESPONSIVE=0
while [ $ISRESPONSIVE != 1 ]; do
    echo -n '.'

    curl -fs --connect-timeout 1 http://$MESOS_MASTER/master/state.json &> /dev/null
    if [ $? -ne 0 ]
    then
        sleep .7
    else
        let ISRESPONSIVE=1
    fi
done
echo
echo 'Mesos is now running'
echo "Dashboard: $MESOS_MASTER"
command -v open >/dev/null 2>&1 && `open http://$MESOS_MASTER/`

# Wait for Marathon
echo
echo 'Waiting for Marathon'
export MARATHON="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$COMPOSE_PROJECT_NAME"_marathon_1):8080"
ISRESPONSIVE=0
while [ $ISRESPONSIVE != 1 ]; do
    echo -n '.'

    curl -fs --connect-timeout 1 http://$MARATHON/v2/info &> /dev/null
    if [ $? -ne 0 ]
    then
        sleep .7
    else
        let ISRESPONSIVE=1
    fi
done
echo
echo 'Marathon is now running'
echo "Dashboard: $MARATHON"
command -v open >/dev/null 2>&1 && `open http://$MARATHON/`

echo
echo 'creating some "hello world" apps'
echo 'the output may be ugly'
curl -X POST http://$MARATHON/v2/apps -d @marathon-tasks/nginx.json -H "Content-type: application/json"
echo
curl -X POST http://$MARATHON/v2/apps -d @marathon-tasks/couchbase.json -H "Content-type: application/json"
echo
#curl -X POST http://$MARATHON/v2/groups -d @marathon-tasks/couchbase-cluster.json -H "Content-type: application/json"
echo

# echo "# execute the following to create two slaves in each of multiple data centers"
# echo "# this parallelizes docker operations in each data center and adds geographic diversity"
# echo
# echo "bash slaves.sh $COMPOSE_PROJECT_NAME $MESOS_MASTER $DOCKER_HOST"
