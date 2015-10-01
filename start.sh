#!/bin/bash

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

# rest a moment to let things settle
sleep 1.3

export CONSUL="$(sdc-listmachines | json -aH -c "'"$COMPOSE_PROJECT_NAME"_consul_1' == this.name" ips.1):8500"
echo
echo 'Consul is now running'
echo "Dashboard: $CONSUL"
command -v open >/dev/null 2>&1 && `open http://$CONSUL/ui/`

export MESOS_MASTER="$(sdc-listmachines | json -aH -c "'"$COMPOSE_PROJECT_NAME"_master_1' == this.name" ips.1):5050"
echo
echo 'Mesos is now running'
echo "Dashboard: $MESOS_MASTER"
command -v open >/dev/null 2>&1 && `open http://$MESOS_MASTER/`

export MARATHON="$(sdc-listmachines | json -aH -c "'"$COMPOSE_PROJECT_NAME"_marathon_1' == this.name" ips.1):8080"
echo
echo 'Marathon is now running'
echo "Dashboard: $MARATHON"
command -v open >/dev/null 2>&1 && `open http://$MARATHON/`

# rest a moment to let things settle
sleep 1.3

echo
echo 'creating some "hello world" apps'
echo 'the output may be ugly'
curl -X POST http://$MARATHON/v2/apps -d @marathon-tasks/nginx.json -H "Content-type: application/json"
echo
curl -X POST http://$MARATHON/v2/apps -d @marathon-tasks/couchbase.json -H "Content-type: application/json"
echo
#curl -X POST http://$MARATHON/v2/groups -d @marathon-tasks/couchbase-cluster.json -H "Content-type: application/json"
echo

echo "# execute the following to create two slaves in each of multiple data centers"
echo "# this parallelizes docker operations in each data center and adds geographic diversity"
echo
echo "bash slaves.sh $COMPOSE_PROJECT_NAME $MESOS_MASTER $DOCKER_HOST"

