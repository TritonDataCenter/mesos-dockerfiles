#!/bin/bash

# Capture the vars from the command line
COMPOSE_PROJECT_NAME=$1
CONSUL=$2
MARATHON=$3

echo "project prefix: $COMPOSE_PROJECT_NAME"
echo "        Consul: $CONSUL"
echo "      Marathon: $MARATHON"

echo
echo 'creating some "hello world" apps'
echo 'the output may be ugly'
curl -X POST http://$MARATHON/v2/apps -d @marathon-tasks/couchbase.json -H "Content-type: application/json"
echo
curl -X POST http://$MARATHON/v2/apps -d @marathon-tasks/couchbase-loadgenerator.json -H "Content-type: application/json"
echo

#
# Wait for a Couchbase instance to register as awaiting configuration in Consul
#
echo
echo 'Waiting for a Couchbase instance to register as awaiting configuration in Consul'
ISRESPONSIVE=0
while [ $ISRESPONSIVE != 1 ]; do
    echo -n '.'

    # get the container ID of a Couchbase instance awaiting configuration
    export COUCHBASECONTAINERID=$(curl -L -s -f http://$CONSUL/v1/health/service/couchbase-unconfigured?passing | json -aH Service.ID | head -1 | sed 's/couchbase-unconfigured-//')
    if [ -n "$COUCHBASECONTAINERID" ]
    then
        # we've got a container ID, move on to the next step
        let ISRESPONSIVE=1
    else
        # nothing registered, just wait
        sleep .7
    fi
done
echo

#
# Wait for Couchbase
#
echo
echo 'Waiting to bootstrap Couchbase'
ISRESPONSIVE=0
while [ $ISRESPONSIVE != 1 ]; do
    echo -n '.'

    docker exec -it $COUCHBASECONTAINERID triton-bootstrap bootstrap benchmark
    if [ $? -eq 0 ]
    then
        # successful docker exec, continue
        let ISRESPONSIVE=1
    else
        # docker exec failed, so wait a moment
        sleep .7
    fi
done
echo

#
# Open the Couchbase dashboard
#
export COUCHBASEHOST="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $COUCHBASECONTAINERID):8091"
echo
echo 'Couchbase cluster running and bootstrapped'
echo "Dashboard: $COUCHBASEHOST"
echo "username=Administrator"
echo "password=password"
command -v open >/dev/null 2>&1 && `open http://$COUCHBASEHOST/index.html#sec=servers`
