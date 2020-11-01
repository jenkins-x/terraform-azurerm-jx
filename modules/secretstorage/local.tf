locals {
  vault_name    = substr(join("", regexall(var.storage_account_regex, "vault${var.cluster_name}${var.cluster_id}")), 0, 24)
  key_name      = "${var.cluster_name}-${var.cluster_id}"
  identity_name = "key-vault-${var.cluster_id}"
}
