/* Talos Image Factory */

data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version

  filters = {
    names = var.talos_extensions_names
  }
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  architecture  = var.talos_architecture
  platform      = var.talos_platform
}

/* Talos Machine */

data "talos_machine_configuration" "this" {
  for_each      = { for node in var.talos_nodes : node.name => node }
  talos_version = var.talos_version

  cluster_name     = var.talos_cluster_name
  cluster_endpoint = local.talos_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  machine_type     = each.value.type

  config_patches = flatten([
    templatefile("${path.module}/templates/node.yaml.tftpl", {
      proxmox_node        = each.value.proxmox_node_name
      cilium_manifest     = file("${path.module}/../kubernetes/templates/cilium.yaml")
      talos_factory_image = data.talos_image_factory_urls.this.urls.installer,
    }),
    [
      each.value.type == "controlplane"
      ? templatefile("${path.module}/templates/controlplane.yaml.tftpl", {})
      : templatefile("${path.module}/templates/worker.yaml.tftpl", {})
    ]
  ])
}

/* Talos Client */

data "talos_client_configuration" "this" {
  cluster_name = var.talos_cluster_name

  endpoints            = [for node in var.talos_nodes : node.network_address if node.type == "controlplane"]
  client_configuration = talos_machine_secrets.this.client_configuration
}

/* Talos Cluster */

data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration

  worker_nodes        = [for node in var.talos_nodes : node.network_address if node.type == "worker"]
  control_plane_nodes = [for node in var.talos_nodes : node.network_address if node.type == "controlplane"]

  skip_kubernetes_checks = true
  endpoints              = data.talos_client_configuration.this.endpoints

  timeouts = {
    read = "30m"
  }

  depends_on = [
    talos_machine_bootstrap.this
  ]
}
