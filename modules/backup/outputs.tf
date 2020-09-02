output "backup_container_url" {
  value = length(azurerm_storage_account.velero) > 0 ? "${azurerm_storage_account.velero[0].primary_blob_endpoint}${azurerm_storage_container.velero[0].name}" : ""
}
output "velero_storage_account" {
  value = length(azurerm_storage_account.velero) > 0 ? azurerm_storage_account.velero.0.name : ""
}
output "velero_storage_resouce_group_name" {
  value = length(azurerm_storage_account.velero) > 0 ? var.resource_group : ""
}
output "velero_container_name" {
  value = length(azurerm_storage_account.velero) > 0 ? azurerm_storage_container.velero.0.name : ""
}
output "velero_client_id" {
  value = length(azurerm_storage_account.velero) > 0 ? azuread_application.velero.0.application_id : ""
}
output "velero_client_secret" {
  value = length(azurerm_storage_account.velero) > 0 ? random_string.velero.0.result : ""
}
