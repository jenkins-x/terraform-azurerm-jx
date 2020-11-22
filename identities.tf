data "azurerm_client_config" "current" {
}

resource "azuread_application" "jx_health" {
  name = "jx_health-${local.cluster_id}"
}

resource "azuread_service_principal" "jx_health" {
  application_id = azuread_application.jx_health.application_id
}

resource "random_string" "jx_health" {
  length           = 32
  special          = true
  override_special = "_"
}

resource "azuread_application_password" "jx_health" {
  application_object_id = azuread_application.jx_health.id
  value                 = random_string.jx_health.result
  end_date_relative     = "87600h"
}

resource "azurerm_user_assigned_identity" "vault_identity" {
  location            = var.location
  resource_group_name = local.identity_resource_group_name
  name                = "key-vault-${local.cluster_id}"
}

locals {
  jx_health_client_id            = azuread_application.jx_health.application_id
  jx_health_service_principal_id = azuread_service_principal.jx_health.object_id
  jx_health_client_secret        = random_string.jx_health.result
  key_vault_acls_principal_ids = {
    "terraform_current_user" : data.azurerm_client_config.current.object_id,
    "jx_health" : azuread_service_principal.jx_health.object_id,
    "vault_workload_identity" : azurerm_user_assigned_identity.vault_identity.principal_id,
    "kubelet_identity" : module.cluster.kubelet_identity_id,
  }
}
