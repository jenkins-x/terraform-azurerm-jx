data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "vault" {
  name                        = local.vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "terraform_vault_access_policy" {
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = var.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get",
    "list",
    "create",
    "delete",
    "update",
    "wrapKey",
    "unwrapKey",
  ]
}

resource "azurerm_user_assigned_identity" "key_vault_identity" {
  count               = var.enable_workload_identity ? 1 : 0
  location            = var.location
  resource_group_name = var.identity_resource_group_name
  name                = local.identity_name
}

resource "azurerm_key_vault_access_policy" "kubelet_vault_access_policy" {
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = var.tenant_id
  object_id = var.enable_workload_identity ? azurerm_user_assigned_identity.key_vault_identity.0.principal_id : var.kubelet_identity_id

  key_permissions = [
    "get",
    "list",
    "create",
    "delete",
    "update",
    "wrapKey",
    "unwrapKey",
  ]

  secret_permissions = [
    "get",
    "set"
  ]
}
