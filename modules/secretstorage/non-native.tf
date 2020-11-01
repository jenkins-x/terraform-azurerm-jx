resource "azurerm_storage_account" "vault" {
  count                    = var.enable_native ? 0 : 1
  name                     = local.vault_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_storage_container" "vault" {
  count                = var.enable_native ? 0 : 1
  name                 = "vault"
  storage_account_name = azurerm_storage_account.vault.0.name
}

resource "null_resource" "delay" {
  depends_on = [azurerm_key_vault_access_policy.terraform_vault_access_policy]
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "azurerm_key_vault_key" "generated" {
  depends_on   = [azurerm_key_vault_access_policy.terraform_vault_access_policy, null_resource.delay]
  count        = var.enable_native ? 0 : 1
  name         = local.key_name
  key_vault_id = azurerm_key_vault.vault.id
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
