output "fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}
output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
}
output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate
}
output "client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key
}
output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate
}
output "kube_config_admin_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}
output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}
output "kubelet_identity_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}
output "jenkins_x_namespace" {
  value = var.jenkins_x_namespace
}
