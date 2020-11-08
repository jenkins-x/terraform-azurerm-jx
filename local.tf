resource "random_pet" "pet" {
}

resource "random_id" "random" {
  byte_length = 6
}

locals {
  prefix                           = "tf-jx"
  alphanum_regex                   = "[[:alnum:]]+"
  secret_infra_namespace           = "secret-infra"
  identity_resource_group_name     = module.cluster.node_resource_group
  tenant_id                        = data.azurerm_client_config.current.tenant_id
  cluster_id                       = random_id.random.hex
  kubernetes_external_secret_name  = "kubernetes-external-secrets-azure-key-vault"
  cluster_name                     = var.cluster_name != "" ? var.cluster_name : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  dns_prefix                       = var.dns_prefix != "" ? var.dns_prefix : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  network_resource_group_name      = var.network_resource_group_name != "" ? var.network_resource_group_name : "${local.prefix}-rg-net-${random_pet.pet.id}"
  cluster_resource_group_name      = var.cluster_resource_group_name != "" ? var.cluster_resource_group_name : "${local.prefix}-rg-cluster-${random_pet.pet.id}"
  cluster_node_resource_group_name = var.cluster_node_resource_group_name != "" ? var.cluster_node_resource_group_name : "${local.prefix}-rg-cluster-node-${random_pet.pet.id}"
  network_name                     = var.network_name != "" ? var.network_name : "${local.prefix}-${random_pet.pet.id}"
  subnet_name                      = var.subnet_name != "" ? var.subnet_name : "${local.prefix}-${random_pet.pet.id}"
  dns_resource_group_name          = var.dns_resource_group_name != "" ? var.dns_resource_group_name : "${local.prefix}-rg-dns-${random_pet.pet.id}"
  domain_name                      = var.domain_name != "" ? var.domain_name : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  registry_resource_group_name     = var.registry_resource_group_name != "" ? var.registry_resource_group_name : "${local.prefix}-rg-registry-${random_pet.pet.id}"
  container_registry_name          = var.container_registry_name != "" ? var.container_registry_name : replace("${local.prefix}${random_pet.pet.id}", "-", "")
  secrets_resource_group_name      = var.secret_management.resource_group_name != "" ? var.secret_management.resource_group_name : "${local.prefix}-rg-secrets-${random_pet.pet.id}"

  version_stream_url = var.version_stream_url != "" ? var.version_stream_url : var.is_jx2 ? "https://github.com/jenkins-x/jenkins-x-versions.git" : "https://github.com/jenkins-x/jxr-versions.git"

  vault_identity_name = "key-vault-${local.cluster_id}"
  identities = var.enable_workload_identity ? [{
    name       = local.vault_identity_name
    namespace  = local.secret_infra_namespace
    resourceId = module.secretstorage.secret_workload_identity.resourceId
    clientId   = module.secretstorage.secret_workload_identity.clientId
    binding = {
      name     = local.vault_identity_name
      selector = local.vault_identity_name
    }
  }] : []
}
