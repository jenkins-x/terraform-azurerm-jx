resource "azurerm_key_vault" "vault" {
  count                       = var.enable_vault ? 1 : 0
  name                        = local.vault_name
  location                    = var.location
  resource_group_name         = var.resource_group
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"

}

resource "azurerm_key_vault_access_policy" "terraform_vault_access_policy" {
  count        = var.enable_vault ? 1 : 0
  key_vault_id = azurerm_key_vault.vault.0.id

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

resource "azurerm_key_vault_access_policy" "kubelet_vault_access_policy" {
  count        = var.enable_vault ? 1 : 0
  key_vault_id = azurerm_key_vault.vault.0.id

  tenant_id = var.tenant_id
  object_id = var.kubelet_identity_id

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

resource "azurerm_key_vault_key" "generated" {
  depends_on   = [azurerm_key_vault_access_policy.terraform_vault_access_policy]
  count        = var.enable_vault ? 1 : 0
  name         = local.key_name
  key_vault_id = azurerm_key_vault.vault.0.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
