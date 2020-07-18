output "backup_container_url" {
  value = length(azurerm_storage_account.velero) > 0 ? "${azurerm_storage_account.velero[0].primary_blob_endpoint}${azurerm_storage_container.velero[0].name}" : ""
}
output "velero_storage_account" {
  value = length(azurerm_storage_account.velero) > 0 ? azurerm_storage_account.velero.0.name : ""
}
output "backup_bucket_name" {
  value = length(azurerm_storage_account.velero) > 0 ? azurerm_storage_container.velero.0.name : ""
}
