

resource "azurerm_key_vault" "vault" {
  name                        = local.vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "vault_access_policy" {
  for_each     = var.key_vault_acls_principal_ids
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = var.tenant_id
  object_id = each.value

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
