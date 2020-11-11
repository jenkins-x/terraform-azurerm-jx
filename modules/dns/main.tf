data "azurerm_dns_zone" "apex_domain_zone" {
  count = var.apex_domain_integration_enabled && var.enabled ? 1 : 0
  name  = var.apex_domain
}

resource "azurerm_dns_zone" "dns" {
  count               = var.enabled ? 1 : 0
  name                = join(".", [var.domain_name, var.apex_domain])
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_ns_record" "subdomain_ns_delegation" {
  count               = var.apex_domain_integration_enabled && var.enabled ? 1 : 0
  name                = var.domain_name
  zone_name           = data.azurerm_dns_zone.apex_domain_zone.0.name
  resource_group_name = var.apex_resource_group_name
  ttl                 = 300
  records             = azurerm_dns_zone.dns[0].name_servers
}

resource "azurerm_role_assignment" "Give_ExternalDNS_SP_Contributor_Access_to_ResourceGroup" {
  count                = var.enabled ? 1 : 0
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = var.kubelet_identity_id
}
