```
docker run \
-d \
-P \
--name=mesos-slave \
--restart=always \
-e "TLSCA=`cat "$DOCKER_CERT_PATH"/ca.pem`" \
-e "TLSCERT=`cat "$DOCKER_CERT_PATH"/cert.pem`" \
-e "TLSKEY=`cat "$DOCKER_CERT_PATH"/key.pem`" \
-e "DOCKER_HOST" \
-e "MESOS_MASTER=`docker inspect mesos_master | json -a NetworkSettings.IPAddress`:5050" \
misterbisson/triton-mesos-slave
```

