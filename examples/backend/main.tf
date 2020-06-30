terraform {
  # https://www.terraform.io/docs/backends/types/azurerm.html
  backend "azurerm" {
    resource_group_name  = "<StorageAccount-ResourceGroup>"
    storage_account_name = "<StorageAccount-Name>"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

module "aks-jx" {
  source = "jenkins-x/aks-jx/aks"
}
