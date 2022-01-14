# Ansible Playbook - HA Rancher RKE Cluster
Ansible playbook to create a 3 node HA Rancher Kubernetes Cluster. This is based on Rancher's [reference architecture](https://rancher.com/docs/rancher/v2.6/en/installation/resources/k8s-tutorials/infrastructure-tutorials/infra-for-ha/). This assumes you've got an external load balancer handling SSL termination, the default IP is already set on each VM, and this is running on Ubuntu 20.04.

This will deploy a Rancher with a trusted internal CA, and enable full end-to-end HTTPS for all Rancher communication and management. If you're using a public CA trusted by Ubuntu 20.04 by default, you can remove the CA Certs parts in the `Common` role and the `Kubernetes/Rancher` roles. Regrettably, even if the host system trusts your CA, the Rancher docker container will not. See the other requirements section below for more info about certificate requirements.

The UFW setup is overly tiresome due to [THIS](https://github.com/ansible-collections/community.general/issues/2336) happening with all changes, not just disable, which is due to [THIS](https://bugs.launchpad.net/ufw/+bug/1911637) underlying issue in UFW.

I'm including the `common` role because these settings are applied to my base image, and I've not tested this setup at all without them. YMMV.

For more info see the [Wiki](https://github.com/robharman/Ansible-Rancher/wiki).
