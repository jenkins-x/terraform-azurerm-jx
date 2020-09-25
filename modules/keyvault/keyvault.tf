resource "azurerm_key_vault" "key_vault" {
  count                       = var.enable_keyvault ? 1 : 0
  name                        = local.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  count        = var.enable_keyvault ? 1 : 0
  key_vault_id = azurerm_key_vault.key_vault.0.id

  tenant_id = var.tenant_id
  object_id = azuread_service_principal.keyvault.0.id

  key_permissions = [
    "get"
  ]

  secret_permissions = [
    "get"
  ]
}
