data "azurerm_resource_group" "aks_node_rg" {
  name = var.cluster_node_resource_group
}

resource "helm_release" "aad_pod_id" {
  count            = var.enable ? 1 : 0
  name             = "aad-pod-identity"
  repository       = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart            = "aad-pod-identity"
  version          = "2.0.2"
  namespace        = local.workload_identity_namespace
  create_namespace = true
  timeout          = 600
  values = [
    <<EOF
${local.azureIdentities}
EOF
  ]
}

# Following roles are required by AAD Pod Identity and must be assigned to the Kubelet Identity
# https://github.com/Azure/aad-pod-identity/blob/master/docs/readmes/README.role-assignment.md
resource "azurerm_role_assignment" "vm_contributor" {
  count                = var.enable ? 1 : 0
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = var.kubelet_identity_id
}

resource "azurerm_role_assignment" "mi_operator" {
  count                = var.enable ? 1 : 0
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.kubelet_identity_id
}
