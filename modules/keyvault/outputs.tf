output "key_vault_name" {
  value = var.enable_keyvault ? azurerm_key_vault.key_vault.0.name : ""
}
output "key_vault_client_id" {
  value = var.enable_keyvault ? azuread_application.keyvault.0.application_id : ""
}
output "key_vault_client_secret" {
  value = var.enable_keyvault ? random_string.keyvault.0.result : ""
}
