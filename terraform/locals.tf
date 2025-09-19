locals {
  # Talos image name (talos-v1.11.1-nocloud-amd64.iso)
  talos_image_name = format(
    "talos-%s-%s-%s.iso",
    var.talos_version,
    var.talos_platform,
    var.talos_architecture,
  )

  talos_cp_address = tolist([for node in var.talos_nodes : node.network_address if node.type == "controlplane"])[0]
  talos_endpoint   = "https://${local.talos_cp_address}:6443"
}
