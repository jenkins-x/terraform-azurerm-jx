resource "azurerm_storage_account" "vault" {
  count                    = var.enable_vault ? 1 : 0
  name                     = local.vault_name
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"

}

resource "azurerm_storage_container" "vault" {
  count                = var.enable_vault ? 1 : 0
  name                 = "vault"
  storage_account_name = azurerm_storage_account.vault.0.name
}
