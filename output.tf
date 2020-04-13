output "resource_group" {
  value = azurerm_resource_group.cluster.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.cluster.name
}

output "kube_config" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.cluster.kube_config_raw
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.cluster.node_resource_group
}

