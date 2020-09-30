locals {
  identity_name = "key-vault-${var.cluster_id}"
}

resource "azurerm_user_assigned_identity" "key_vault_identity" {
  count               = var.enable_workload_identity && var.enable_vault ? 1 : 0
  location            = var.location
  resource_group_name = var.identity_resource_group_name
  name                = local.identity_name
}
