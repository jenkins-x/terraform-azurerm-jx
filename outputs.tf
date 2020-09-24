output "subscription_id" {
  description = "Id of subscription in which resources are created"
  value       = data.azurerm_subscription.current.subscription_id
}
output "jx_requirements" {
  description = "The jx-requirements rendered output"
  value       = local.content
}
output "cluster_name" {
  value = local.cluster_name
}
output "dns_prefix" {
  value = local.dns_prefix
}
output "network_resource_group" {
  value = local.network_resource_group
}
output "cluster_resource_group" {
  value = local.cluster_resource_group
}
output "cluster_node_resource_group" {
  value = local.cluster_node_resource_group
}
output "network_name" {
  value = local.network_name
}
output "subnet_name" {
  value = local.subnet_name
}
output "dns_resource_group" {
  value = local.dns_resource_group
}
output "domain_name" {
  value = local.domain_name
}
output "fully_qualified_domain_name" {
  value = module.dns.domain
}
output "kube_admin_config_raw" {
  value     = module.cluster.kube_config_admin_raw
  sensitive = true
}
output "container_registry_name" {
  value = local.container_registry_name
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "vault_storage_account_key" {
  value     = module.vault.vault_storage_account_key
  sensitive = true
}
output "key_vault_client_id" {
  value = module.key_vault.key_vault_client_id
}
output "key_vault_name" {
  value = module.key_vault.key_vault_name
}
output "key_vault_client_secret" {
  value     = module.key_vault.key_vault_client_secret
  sensitive = true
}
output "vault_storage_account_name" {
  value = module.vault.vault_storage_account_name
}
output "vault_name" {
  value = module.vault.vault_keyvault_name
}
output "vault_container_name" {
  value = module.vault.vault_storage_container_name
}
output "vault_key_name" {
  value = module.vault.vault_key_name
}
output "vault_resource_group_name" {
  value = local.secrets_resource_group
}
output "velero_namespace" {
  value = var.velero_namespace
}
output "velero_storage_resource_group_name" {
  value = module.cluster.node_resource_group
}
output "velero_storage_account_name" {
  value = module.backup.velero_storage_account
}
output "velero_container_name" {
  value = module.backup.velero_container_name
}
output "velero_client_id" {
  value = module.backup.velero_client_id
}
output "velero_client_secret" {
  value     = module.backup.velero_client_secret
  sensitive = true
}
output "connect" {
  value = "az aks get-credentials --subscription ${data.azurerm_subscription.current.subscription_id} --name ${local.cluster_name} --resource-group ${local.cluster_resource_group} --admin"
}
output "env_vars" {
  value     = "export VAULT_AZURE_STORAGE_ACCESS_KEY=${module.vault.vault_storage_account_key}"
  sensitive = true
}
