locals {
  key_vault_name = substr(join("", regexall(var.key_vault_regex, "${var.cluster_name}${var.cluster_id}")), 0, 24)
}
