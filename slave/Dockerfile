#
# Triton-optimized Mesos slave
#
FROM 		misterbisson/triton-mesos
MAINTAINER 	Casey Bisson <casey.bisson@gmail.com>

# install wget
RUN apt-get update -q && \
  apt-get install -qy wget

# install Docker
RUN wget -qO- https://get.docker.com/ | sh

# add our start script
ADD sbin /usr/local/sbin

# Docker remote api connection vars
ENV DOCKER_CERT_PATH=/root/.sdc/docker/
ENV DOCKER_CLIENT_TIMEOUT=300
ENV DOCKER_TLS_VERIFY=1

# Mesos resource limits
ENV MESOS_RESOURCES_CPUS=${MESOS_RESOURCES_CPUS:-100}
ENV MESOS_RESOURCES_MEM=${MESOS_RESOURCES_MEM:-245760}
ENV MESOS_RESOURCES_DISK=${MESOS_RESOURCES_DISK:-4096}

CMD ["triton-mesos-slave"]