#!/bin/bash

COMPOSE_PROJECT_NAME=$1

echo "export COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME"
echo "export CONSUL="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$COMPOSE_PROJECT_NAME"_consul_1):8500""
echo "export MESOS_MASTER="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$COMPOSE_PROJECT_NAME"_master_1):5050""
echo "export MARATHON="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$COMPOSE_PROJECT_NAME"_marathon_1):8080""

echo 'echo "CONSUL, MESOS_MASTER, and MARATHON environment variables now set."'