output "vault_storage_account_key" {
  value = var.external_vault ? "" : azurerm_storage_account.vault.0.primary_access_key
}
output "vault_storage_account_name" {
  value = var.external_vault ? "" : azurerm_storage_account.vault.0.name
}
output "vault_storage_container_name" {
  value = var.external_vault ? "" : azurerm_storage_container.vault.0.name
}
output "vault_key_name" {
  value = var.external_vault ? "" : azurerm_key_vault_key.generated.0.name
}
output "vault_keyvault_name" {
  value = var.external_vault ? "" : azurerm_key_vault.vault.0.name
}
