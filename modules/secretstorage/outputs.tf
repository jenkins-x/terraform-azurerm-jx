output "storage_account_key" {
  value = var.enable_native ? "" : azurerm_storage_account.vault.0.primary_access_key
}
output "storage_account_name" {
  value = var.enable_native ? "" : azurerm_storage_account.vault.0.name
}
output "storage_container_name" {
  value = var.enable_native ? "" : azurerm_storage_container.vault.0.name
}
output "key_name" {
  value = var.enable_native ? "" : azurerm_key_vault_key.generated.0.name
}
output "keyvault_name" {
  value = azurerm_key_vault.vault.name
}
