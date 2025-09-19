terraform {
  required_version = ">= 1.13.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.2"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
  }
}
