resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.cluster_version

  default_node_pool {
    name           = "default"
    vm_size        = var.node_size
    vnet_subnet_id = var.vnet_subnet_id
    node_count     = var.node_count
  }

  network_profile {
    network_plugin = "kubenet"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed = true
    }
  }
}

resource "kubernetes_namespace" "jenkins_x_namespace" {
  metadata {
    name = var.jenkins_x_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}