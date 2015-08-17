#
# Triton-optimized Mesos master
#
FROM 		misterbisson/triton-mesos
MAINTAINER 	Casey Bisson <casey.bisson@gmail.com>

ENV MESOS_CLUSTER=${MESOS_CLUSTER:-Triton-Mesos}
ENV MESOS_PORT=${MESOS_PORT:-5050}
ENV MESOS_WORK_DIR=${MESOS_WORK_DIR:-/var/lib/mesos}
ENV MESOS_ZK=${MESOS_ZK:-zk://zookeeper:2181}

EXPOSE $MESOS_PORT

CMD ["/usr/local/sbin/mesos-master"]