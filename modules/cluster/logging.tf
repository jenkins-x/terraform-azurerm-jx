resource "azurerm_log_analytics_workspace" "cluster" {
  count               = var.enable_log_analytics ? 1 : 0
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.logging_retention_days
}
