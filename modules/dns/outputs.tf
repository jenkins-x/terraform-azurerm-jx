output "domain" {
  value = var.enabled ? trimprefix(join(".", [var.domain_name, var.apex_domain]), ".") : ""
}
output "name_servers" {
  value = var.enabled ? azurerm_dns_zone.dns.0.name_servers : []
}
output "tenant_id" {
  value = var.enabled ? var.tenant_id : ""
}
output "subscription_id" {
  value = var.enabled ? var.subscription_id : ""
}
output "resource_group_name" {
  value = var.enabled ? var.resource_group_name : ""
}
