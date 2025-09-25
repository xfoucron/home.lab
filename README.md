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
talos_version = "v1.11.1"

talos_cluster_name = "k8s-home-lab"

talos_nodes = [
  {
    proxmox_id        = 151
    proxmox_node_name = "proxmox01"

    name = "K8SCP01"
    type = "controlplane"

    cpu    = 2
    memory = 2048

    disk      = 40
    datastore = "local-lvm"

    network_prefix  = 24
    network_address = "192.168.0.151"
    network_gateway = "192.168.0.254"
  },
  {
    proxmox_id        = 152
    proxmox_node_name = "proxmox01"

    name = "K8SWO01"
    type = "worker"

    cpu    = 4
    memory = 8192

    disk      = 40
    datastore = "local-lvm"

    network_prefix  = 24
    network_address = "192.168.0.152"
    network_gateway = "192.168.0.254"
  },
  {
    proxmox_id        = 153
    proxmox_node_name = "proxmox01"

    name = "K8SWO02"
    type = "worker"

    cpu    = 4
    memory = 8192

    disk      = 40
    datastore = "local-lvm"

    network_prefix  = 24
    network_address = "192.168.0.153"
    network_gateway = "192.168.0.254"
  }
]

```

Apply the changes :

```shell
terraform apply -var-file your.tfvars
```

## Storage (NFS, ISCSI)

I'm using [democratic-csi](https://github.com/democratic-csi/democratic-csi) for storage.

Example for TrueNAS SCALE 25, you can edit `kubernetes/values/democratic-csi/values.yaml` with your values :

```text
TRUENAS_HOST      : IP / FQDN of the TrueNAS instance.
TRUENAS_API_KEY   : the TrueNAS API Key to authenticate.
STORAGE_BASE_PATH : the dataset to store PVC.
```

Create the namespace, and install the chart :

```shell
kubectl apply --filename kubernetes/values/democratic-csi/namespace.yaml

helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm upgrade \
  democratic-csi-nfs \
  --install \
  --values kubernetes/values/democratic-csi/values.yaml \
  --namespace democratic-csi \
  democratic-csi/democratic-csi

```

[!] If you don't plan to use storage, you can remove on the `node.yaml.tftpl` file these lines :

```yaml
    - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/refs/heads/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
    - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/refs/heads/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
    - https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/refs/heads/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
```