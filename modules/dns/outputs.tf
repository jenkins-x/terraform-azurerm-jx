output "domain" {
  value = var.enabled ? trimprefix(join(".", [var.domain_name, var.apex_domain]), ".") : ""
}
output "azure_json" {
  value = var.enabled ? jsonencode({
    "tenantId" : var.tenant_id,
    "subscriptionId" : var.subscription_id,
    "resourceGroup" : var.resource_group_name,
    "useManagedIdentityExtension" : true
  }) : ""
}
output "secret_name" {
  value = var.enabled ? local.external_dns_secret_name : ""
}
