resource "azurerm_container_registry" "acr" {
  count               = var.create_registry ? 1 : 0
  name                = var.container_registry_name
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Basic"
}

resource "azurerm_role_assignment" "acr" {
  count                = var.create_registry ? 1 : 0
  scope                = azurerm_container_registry.acr.0.id
  role_definition_name = "AcrPull"
  principal_id         = var.kubelet_identity_id
}
