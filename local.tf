resource "random_pet" "pet" {
}


locals {
  prefix                 = "tf-jx"
  cluster_name           = var.cluster_name != "" ? var.cluster_name : "${local.prefix}-${random_pet.pet.id}"
  dns_prefix             = var.dns_prefix != "" ? var.dns_prefix : "${local.prefix}-${random_pet.pet.id}"
  network_resource_group = var.network_resource_group != "" ? var.network_resource_group : "${local.prefix}-${random_pet.pet.id}"
  cluster_resource_group = var.cluster_resource_group != "" ? var.cluster_resource_group : "${local.prefix}-${random_pet.pet.id}"
  network_name           = var.network_name != "" ? var.network_name : "${local.prefix}-${random_pet.pet.id}"
  subnet_name            = var.subnet_name != "" ? var.subnet_name : "${local.prefix}-${random_pet.pet.id}"
  dns_resource_group     = var.dns_resource_group != "" ? var.dns_resource_group : "${local.prefix}-${random_pet.pet.id}"
  domain_name            = var.domain_name != "" ? var.domain_name : "${local.prefix}-${random_pet.pet.id}"
}
