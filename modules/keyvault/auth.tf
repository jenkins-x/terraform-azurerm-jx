
resource "azuread_application" "keyvault" {
  count = var.enable_keyvault ? 1 : 0
  name  = "jx-keyvault-${var.cluster_id}"
}


resource "azuread_service_principal" "keyvault" {
  count          = var.enable_keyvault ? 1 : 0
  application_id = azuread_application.keyvault.0.application_id
}

resource "random_string" "keyvault" {
  count            = var.enable_keyvault ? 1 : 0
  length           = 32
  special          = true
  override_special = "_"
}

resource "azuread_application_password" "keyvault" {
  count                 = var.enable_keyvault ? 1 : 0
  application_object_id = azuread_application.keyvault.0.id
  value                 = random_string.keyvault.0.result
  end_date_relative     = "87600h"
}
