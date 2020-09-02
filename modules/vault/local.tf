locals {
  vault_name = substr("vault${var.cluster_name}${var.cluster_id}", 0, 24)
  key_name   = "${var.cluster_name}-${var.cluster_id}"
}
