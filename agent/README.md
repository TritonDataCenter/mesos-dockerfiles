# Triton Mesos Agent

[Joyent Triton](https://www.joyent.com/triton) is a container-native environment, meaning that containers run on multi-tenant bare metal, not in virtual machines. This is uniquely possible because of the security provided in Triton's SmartOS container hypervisor, but it also changes the relationship between Mesos and the infrastructure.

This allows Mesos tasks to scale in the cloud without pre-provisioning virtual machines or single-tenant bare metal servers. More importantly, it allows tasks to scale down without the trouble of needing to consolidate tasks on to a smaller set of resources.

## No virtual machines, no pre-provisioning

To support this, the agent _doesn't run inside a VM_ or on a single-tenant bare metal server. Instead, the agent is connected to Triton in a way that allows it to provision and manage Docker containers running on the bare metal. Paying for containers, rather than VMs, means that you pay for the resources needed to support the current load, not the resources needed to support maximum load. This elasticity allows more efficient use of resources and reduces costs while also offering better, bare metal performance. More importantly, it's just easier that way.

## Provisions via Triton's Docker Remote API

The agent provisions and manages Mesos tasks via the [Docker Remote API](https://docs.joyent.com/public-cloud/api-access/docker) in a Triton data center, and for now, that requires the private key for a user that has permission to connect to that API. The Triton Mesos Agent Docker image receives the keys and other user details as environment variables passed during `docker run...`. The `Dockerfile` in this directory and the `start.sh` that is used to deploy the composed environment work together to fetch the data and pass it into the container.

