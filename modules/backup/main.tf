data "azurerm_client_config" "current" {
}

// ----------------------------------------------------------------------------
// Setup Azure Velero Identity and Storage Accounts
// ----------------------------------------------------------------------------

resource "azuread_application" "velero" {
  count = var.enable_backup ? 1 : 0
  name  = "velero-${var.cluster_id}"
}
resource "azuread_service_principal" "velero" {
  count          = var.enable_backup ? 1 : 0
  application_id = azuread_application.velero.0.application_id
}

resource "random_string" "velero" {
  count            = var.enable_backup ? 1 : 0
  length           = 32
  special          = true
  override_special = "_"
}

resource "azuread_application_password" "velero" {
  count                 = var.enable_backup ? 1 : 0
  application_object_id = azuread_application.velero.0.id
  value                 = random_string.velero.0.result
  end_date_relative     = "87600h"
}

resource "azurerm_storage_account" "velero" {
  count                    = var.enable_backup ? 1 : 0
  name                     = "backup${var.cluster_id}" // TODO - Put some str length validation in to these vars so we don't blow out 24 chars on account name
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"

}

resource "azurerm_storage_container" "velero" {
  count                = var.enable_backup ? 1 : 0
  name                 = "velero"
  storage_account_name = azurerm_storage_account.velero.0.name
}

resource "azurerm_role_assignment" "Give_Velero_SP_Access_To_Storage_Account" {
  count                = var.enable_backup ? 1 : 0
  scope                = azurerm_storage_account.velero.0.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.velero.0.object_id
}

resource "kubernetes_secret" "velero" {
  count = var.enable_backup ? 1 : 0
  metadata {
    name      = local.velero_secret_name
    namespace = var.velero_namespace
  }

  data = {
    "cloud" = <<EOT
AZURE_CLIENT_SECRET=${random_string.velero.0.result}
AZURE_CLIENT_ID=${azuread_application.velero.0.application_id}
AZURE_TENANT_ID=${data.azurerm_client_config.current.tenant_id}
AZURE_SUBSCRIPTION_ID=${data.azurerm_client_config.current.subscription_id}
    EOT
  }
}

// ----------------------------------------------------------------------------
// Setup Kubernetes Velero namespace and service account
// ----------------------------------------------------------------------------
# resource "kubernetes_namespace" "velero_namespace" {
#   count = var.enable_backup ? 1 : 0

#   metadata {
#     name = var.velero_namespace
#   }

#   lifecycle {
#     ignore_changes = [
#       metadata[0].labels,
#       metadata[0].annotations,
#     ]
#   }
# }
