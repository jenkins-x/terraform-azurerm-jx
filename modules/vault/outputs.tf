output "vault_storage_account_key" {
  value = var.enable_vault ? azurerm_storage_account.vault.0.primary_access_key : ""
}
output "vault_storage_account_name" {
  value = var.enable_vault ? azurerm_storage_account.vault.0.name : ""
}
output "vault_storage_container_name" {
  value = var.enable_vault ? azurerm_storage_container.vault.0.name : ""
}
output "vault_key_name" {
  value = var.enable_vault ? azurerm_key_vault_key.generated.0.name : ""
}
output "vault_keyvault_name" {
  value = var.enable_vault ? azurerm_key_vault.vault.0.name : ""
}
output "vault_identity" {
  value = var.enable_vault && var.enable_workload_identity ? {
    resourceId = var.enable_vault && var.enable_workload_identity ? azurerm_user_assigned_identity.key_vault_identity.0.id : ""
    clientId   = var.enable_vault && var.enable_workload_identity ? azurerm_user_assigned_identity.key_vault_identity.0.client_id : ""
  } : {}
}
