# home.lab

## Getting started

The infrastructure is deployed using Terraform.

You'll need to generate the Cilium Kubernetes manifest file :

```shell
helm repo add cilium https://helm.cilium.io/

helm template \
  cilium \
  cilium/cilium \
  --values kubernetes/values/cilium/values.yaml \
  --namespace kube-system > kubernetes/templates/cilium.yaml
```

Then, you'll have to add your Proxmox credentials using
[environment variables](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#environment-variables-summary) :

```shell
export PROXMOX_VE_USERNAME=test@pam
export PROXMOX_VE_PASSWORD=SecurePassword
export PROXMOX_VE_INSECURE=true
export PROXMOX_VE_ENDPOINT=https://proxmox01.home.lab
```

Create your inventory (demo inventory contains one CP and two workers nodes) :
```terraform
talos_version  = "v1.11.1"

talos_cluster_name = "k8s-home-lab"

talos_nodes = [
  {
    proxmox_id = 151
    proxmox_node_name = "proxmox01"
    
    name = "K8SCP01"
    type = "controlplane"
    
    cpu    = 2
    memory = 2048
    
    disk      = 40
    datastore = "local-lvm"
    
    network_prefix = 24
    network_address = "192.168.0.151"
    network_gateway = "192.168.0.254"
  },
  {
    proxmox_id = 152
    proxmox_node_name = "proxmox01"

    name = "K8SWO01"
    type = "worker"

    cpu    = 4
    memory = 8192

    disk      = 40
    datastore = "local-lvm"

    network_prefix = 24
    network_address = "192.168.0.152"
    network_gateway = "192.168.0.254"
  },
  {
    proxmox_id = 153
    proxmox_node_name = "proxmox01"

    name = "K8SWO02"
    type = "worker"

    cpu    = 4
    memory = 8192

    disk      = 40
    datastore = "local-lvm"

    network_prefix = 24
    network_address = "192.168.0.153"
    network_gateway = "192.168.0.254"
  }
]

```

Apply the changes :
```shell
terraform apply -var-file your.tfvars
```
