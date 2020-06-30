module "jx-aks" {
  source                   = "jenkins-x/aks-jx/aks"
  cluster_name             = "jenkinsxcluster"
  node_count               = 3
  node_size                = "Standard_D2ds_v4"
  location                 = "australiasoutheast"
  network_resource_group   = "network_rg"
  cluster_rersouorce_group = "cluster_rg"
  vnet_cidr                = "10.24.0.0/16"
  subnet_cidr              = "10.24.0.0/24"
}
