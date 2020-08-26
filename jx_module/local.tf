resource "random_pet" "pet" {
}

resource "random_id" "random" {
  byte_length = 6
}

locals {
  prefix                  = "tf-jx"
  external_vault          = var.vault_url != "" ? true : false
  tenant_id               = data.azurerm_client_config.current.tenant_id
  cluster_id              = random_id.random.hex
  cluster_name            = var.cluster_name != "" ? var.cluster_name : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  dns_prefix              = var.dns_prefix != "" ? var.dns_prefix : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  network_resource_group  = var.network_resource_group != "" ? var.network_resource_group : "${local.prefix}-rg-net-${random_pet.pet.id}"
  cluster_resource_group  = var.cluster_resource_group != "" ? var.cluster_resource_group : "${local.prefix}-rg-cluster-${random_pet.pet.id}"
  network_name            = var.network_name != "" ? var.network_name : "${local.prefix}-${random_pet.pet.id}"
  subnet_name             = var.subnet_name != "" ? var.subnet_name : "${local.prefix}-${random_pet.pet.id}"
  dns_resource_group      = var.dns_resource_group != "" ? var.dns_resource_group : "${local.prefix}-rg-dns-${random_pet.pet.id}"
  domain_name             = var.domain_name != "" ? var.domain_name : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  registry_resource_group = var.registry_resource_group != "" ? var.registry_resource_group : "${local.prefix}-rg-registry-${random_pet.pet.id}"
  container_registry_name = var.container_registry_name != "" ? var.container_registry_name : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  vault_resource_group    = var.vault_resource_group != "" ? var.vault_resource_group : "${local.prefix}-rg-vault-${random_pet.pet.id}"
}
