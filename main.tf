module "azure-provider" {
  source = "./provider"
}

resource "azurerm_resource_group" "cluster" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "network" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.cluster.location
  resource_group_name = azurerm_resource_group.cluster.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.cluster.name
  address_prefix       = var.subnet_prefixes
  virtual_network_name = azurerm_virtual_network.network.name

}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.cluster.location
  resource_group_name = azurerm_resource_group.cluster.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  linux_profile {
    admin_username = var.admin_user

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.subnet.id
    max_pods       = 250
    type           = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
  }

  role_based_access_control {
    enabled = true
  }

  service_principal {
    client_id     = var.service_principal_id
    client_secret = var.service_principal_secret
  }

  tags = {
    Environment = var.targeted_environment
  }

}