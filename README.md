# Ansible Rancher Playbook
Ansible playbook to create a 3 node HA Rancher Kubernetes Cluster. This is based on Rancher's [reference architecture](https://rancher.com/docs/rancher/v2.6/en/installation/resources/k8s-tutorials/infrastructure-tutorials/infra-for-ha/). This assumes you've got an external load balancer handling SSL termination, the default IP is already set on each VM, and this is running on Ubuntu 20.04.

This will deploy a Rancher with a trusted internal CA, and enable full end-to-end HTTPS for all Rancher communication and management. If you're using a public CA trusted by Ubuntu 20.04 by default, you can remove the CA Certs parts in the `Common` role and the `Kubernetes/Rancher` roles. Regrettably, even if the host system trusts your CA, the Rancher docker container will not. See the other requirements section below for more info about certificate requirements.

The UFW setup is overly tiresome due to [THIS](https://github.com/ansible-collections/community.general/issues/2336) happening with all changes, not just disable, which is due to [THIS](https://bugs.launchpad.net/ufw/+bug/1911637) underlying issue in UFW.

I'm including the `common` role because these settings are applied to my base image, and I've not tested this setup at all without them. YMMV.

## Security concerns
- While there's a basic server hardening performed on the host, the Kubernetes cluster does not have much/any hardening performed on it.
- You may not want all the packages that are installed in the `install_common` task in the `common` role.
- Ideally, we should all be using ssh certificates instead of ssh keys.
- This allows the ansible user to run kubectl commands, this may or may not be permissible for you.
- The auditd configuration in roles/common/tasks/harden_ubuntu should be tuned to your requirements. As is, this just audits all sudo commands.
- This dynamically generates ssh keys for the rancher user on each host, and temporarily copies the public key to the Ansible server before adding them to the rancher user's `authorized_keys` file. This may not be what you want.
- There's no vault here for anything, and you do need to be able to copy a private key and set the bootstrap password for the Rancher admin page.

## Required Variables
Set the following in your hosts (as templated), or in `group_vars/rancher.yml`
|  Variable Name  |  Type  |                   Purpose                      |
|------------------------|------------|------------------------------------------------|
|       ansible_user        |   string   | Global value of the ansible user account.      |
|   ansible_serveraddress   | ip address | Global value of Ansible server IP. Used for firewall. |
|        env_Domain         |   string   | Global TLD for DNS                             |
|     env_LocalTimeZone     |   string   | Global timezone for cluster.                   |
|      env_LocalNetwork     | ip address | Local subnet, used in netplan.                 |
|     env_GatewayAddress    | ip address | Local gateway address, used in netplan.        |
|    env_PrimaryDNSServer   | ip address | Primary DNS Server IP, used in netplan.        |
|   env_SecondaryDNSServer  | ip address | Secondary DNS Sserver IP, used in netplan.     |
|     env_LoadBalancerIP    | ip address | Load balancer IP address, used for firewall.   |
|       docker_version      |   version  | Global docker version to install. Defaults to 20.10 |
|      rancher_hostname     |   string   | Per cluster. DNS hostname for Rancher. Defaults to `rancher.{{ env_domain }}` |
|     rancher_clustername   |   string   | Per cluster. Internal cluster name for Rancher. Defaults to `{{ rancher_hostname }}_rke` |
|     rancher_dockersh256   |   string   | Per cluster. SHA 256 hash for the Docker install script. Defaults to 20.10 |
|      rancher_installer    |   string   | Per cluster. RKE installer URL.                |
|    rancher_installer256   |   string   | Per cluster. SHA 256 hash for the RKE installer. |
| rancher_managedhostsubnet |   string   | Per managed cluster. Subnet range. Used for firewall. |
| rancher_bootstrappassword |   string   | Per Rancher cluster. Initial setup password for admin user. |
|       vm_ipaddress        |   string   | Per server. Server's primary IP address.                  |
|      vm_initialnode       |    Bool    | Per cluster. Each cluster requires a initial node on which to run the cluster config, and Rancher installation. |
|      vm_dockerdrive       |   string   | Per server. The physical `/dev/` path for the Docker hard drive |
|      kube_clusterips      |   array    | Per cluster. List of cluster IPs to iterate through for firewall |
|       InitialSetup        |    Bool    | Per cluster, or per server. Runs full setup on nodes where this is true. |

## Other Requirements
- Three nodes.
- VM needs to have two NICs (`eth0`)
- VM needs to have a second hard drive.
- Ingress certificate and private key must be saved in `roles/kubernetes/rancher/files` as `rancher-ingress.crt` and `rancher-ingress.key`.
