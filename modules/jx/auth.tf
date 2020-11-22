resource "azurerm_role_assignment" "subscription_contribution" {
  scope                = var.subscription_resource_id
  role_definition_name = "Contributor"
  principal_id         = var.jx_health_service_principal_id
}
