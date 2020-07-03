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
    load_balancer_sku = "Basic"
    network_plugin    = "kubenet"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }
}

resource "azurerm_user_assigned_identity" "mi" {
  name                = var.msi_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

provider "helm" {
  kubernetes {
    load_config_file       = true
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

resource "helm_release" "aad_pod_id" {
  name             = "aad-pod-identity"
  repository       = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart            = "aad-pod-identity"
  version          = "2.0.0"
  namespace        = var.aad_pod_id_ns
  create_namespace = true

  values = [
    <<-EOF
    azureIdentities:
    - name: "${azurerm_user_assigned_identity.mi.name}"
      resourceID: "${azurerm_user_assigned_identity.mi.id}"
      clientID: "${azurerm_user_assigned_identity.mi.client_id}"
      binding:
        name: "${azurerm_user_assigned_identity.mi.name}-identity-binding"
        selector: "${var.aad_pod_id_binding_selector}"
    EOF
  ]
}

data "azurerm_resource_group" "aks_node_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}

# Following roles are required by AAD Pod Identity and must be assigned to the Kubelet Identity
# https://github.com/Azure/aad-pod-identity/blob/master/docs/readmes/README.msi.md#pre-requisites---role-assignments
resource "azurerm_role_assignment" "vm_contributor" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "all_mi_operator" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "mi_operator" {
  scope                = azurerm_user_assigned_identity.mi.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
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