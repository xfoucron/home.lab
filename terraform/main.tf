/* Proxmox File */

resource "proxmox_virtual_environment_download_file" "this" {
  for_each = toset([for node in var.talos_nodes : node.proxmox_node_name])

  node_name = each.value
  url       = data.talos_image_factory_urls.this.urls.iso
  file_name = local.talos_image_name

  content_type = "iso"
  datastore_id = var.proxmox_iso_datastore
}

/* Proxmox Virtual Machine */

resource "proxmox_virtual_environment_vm" "this" {
  for_each = { for node in var.talos_nodes : node.name => node }

  vm_id     = each.value.proxmox_id
  on_boot   = true
  node_name = each.value.proxmox_node_name

  name = each.value.name

  stop_on_destroy = true

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  network_device {
    bridge = "vmbr0"
  }

  cpu {
    type  = "host"
    cores = each.value.cpu
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    interface = "virtio0"

    size         = each.value.disk
    datastore_id = each.value.datastore

    file_id     = proxmox_virtual_environment_download_file.this[each.value.proxmox_node_name].id
    file_format = "raw"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.network_address}/${each.value.network_prefix}"
        gateway = each.value.network_gateway
      }
    }
  }
}

/* Talos Image Factory */

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
      }
    }
  })
}

/* Talos Machine */

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

resource "talos_machine_configuration_apply" "this" {
  for_each = { for node in var.talos_nodes : node.name => node }

  node = each.value.network_address

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.value.name].machine_configuration

  depends_on = [
    proxmox_virtual_environment_vm.this
  ]
}

resource "talos_machine_bootstrap" "this" {
  node                 = [for node in var.talos_nodes : node.network_address if node.type == "controlplane"][0]
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [
    talos_machine_configuration_apply.this
  ]
}

/* Talos Cluster */

resource "talos_cluster_kubeconfig" "this" {
  node                 = [for node in var.talos_nodes : node.name if node.type == "controlplane"][0]
  endpoint             = data.talos_client_configuration.this.endpoints[0]
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [
    talos_machine_bootstrap.this
  ]
}
