/* Talos */

variable "talos_version" {
  description = "The version of Talos to use."
  type        = string
  default     = "v1.11.1"
}

variable "talos_platform" {
  description = "The platform to use."
  type        = string
  default     = "nocloud"
}

variable "talos_architecture" {
  description = "The architecture (amd64, ...) to use."
  type        = string
  default     = "amd64"
}

variable "talos_cluster_name" {
  description = "The name of the Talos cluster."
  type        = string
  default     = "talos-cluster"
}

variable "talos_extensions_names" {
  description = "List of Talos extensions to include."
  type        = list(string)
  default = [
    "siderolabs/qemu-guest-agent",
    "siderolabs/iscsi-tools"
  ]
}

variable "talos_nodes" {
  description = "List of Talos nodes to create."
  type = list(object({
    proxmox_id        = number
    proxmox_node_name = string

    name = string
    type = string

    cpu    = number
    memory = number

    disk      = number
    datastore = string

    network_prefix  = number
    network_address = string
    network_gateway = string
  }))
}

/* Proxmox */

variable "proxmox_iso_datastore" {
  description = "The Proxmox datastore to use for ISO images."
  type        = string
  default     = "local"
}
