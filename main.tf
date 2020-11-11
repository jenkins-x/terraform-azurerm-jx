// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// ----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm = {
      version = ">=2.34.0"
    }
    azuread = {
      version = ">=1.0.0"
    }
    kubernetes = {
      version = ">=1.13.3"
    }
    helm = {
      version = ">=1.3.2"
    }
    random = {
      version = ">=3.0.0"
    }
    null = {
      version = ">=3.0.0"
    }
  }
}

// ----------------------------------------------------------------------------
// Configure providers
// ----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

provider "kubernetes" {
  load_config_file = false

  host = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(
    module.cluster.cluster_ca_certificate,
  )
  client_certificate = base64decode(
    module.cluster.client_certificate,
  )
  client_key = base64decode(
    module.cluster.client_key,
  )
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(
      module.cluster.cluster_ca_certificate,
    )
    client_certificate = base64decode(
      module.cluster.client_certificate,
    )
    client_key = base64decode(
      module.cluster.client_key,
    )
  }
}

// ----------------------------------------------------------------------------
// Retrieve active subscription resources are being created in
// ----------------------------------------------------------------------------
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

// ----------------------------------------------------------------------------
// Setup Azure Resource Groups
// ----------------------------------------------------------------------------

resource "azurerm_resource_group" "network" {
  name     = local.network_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "cluster" {
  name     = local.cluster_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "dns" {
  count    = var.external_dns_enabled ? 1 : 0
  name     = local.dns_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "registry" {
  name     = local.registry_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "secrets" {
  name     = local.secrets_resource_group_name
  location = var.location
}

// ----------------------------------------------------------------------------
// Setup Azure Cluster
// ----------------------------------------------------------------------------

module "cluster" {
  source                   = "./modules/cluster"
  cluster_name             = local.cluster_name
  node_count               = var.node_count
  node_size                = var.node_size
  vnet_subnet_id           = module.vnet.subnet_id
  dns_prefix               = local.dns_prefix
  cluster_version          = var.cluster_version
  location                 = var.location
  resource_group_name      = azurerm_resource_group.cluster.name
  network_resource_group   = local.network_resource_group_name
  jenkins_x_namespace      = var.jenkins_x_namespace
  cluster_network_model    = var.cluster_network_model
  node_resource_group_name = local.cluster_node_resource_group_name
  is_jx2                   = var.is_jx2
  jx_git_url               = var.jx_git_url
  jx_bot_username          = var.jx_bot_username
  jx_bot_token             = var.jx_bot_token
  secrets_infra_namespace  = local.secret_infra_namespace
  enable_log_analytics     = var.enable_log_analytics
  logging_retention_days   = var.logging_retention_days
}

// ----------------------------------------------------------------------------
// Setup Azure Vnet in to which to deploy Cluster
// ----------------------------------------------------------------------------

module "vnet" {
  source         = "./modules/vnet"
  resource_group = azurerm_resource_group.network.name
  vnet_cidr      = var.vnet_cidr
  subnet_cidr    = var.subnet_cidr
  network_name   = local.network_name
  subnet_name    = local.subnet_name
  location       = var.location
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Velero for cluster backups
// ----------------------------------------------------------------------------
module "backup" {
  source                = "./modules/backup"
  enable_backup         = var.enable_backup
  location              = var.location
  resource_group        = module.cluster.node_resource_group
  cluster_id            = local.cluster_id
  cluster_name          = local.cluster_name
  subscription_id       = data.azurerm_client_config.current.subscription_id
  tenant_id             = local.tenant_id
  storage_account_regex = local.alphanum_regex
}

// ----------------------------------------------------------------------------
// Setup Azure DNS (if enabled)
// ----------------------------------------------------------------------------

module "dns" {
  source                          = "./modules/dns"
  resource_group_name             = var.external_dns_enabled ? azurerm_resource_group.dns.0.name : ""
  apex_resource_group_name        = var.apex_domain_resource_group_name
  apex_domain                     = var.apex_domain
  domain_name                     = local.domain_name
  enabled                         = var.external_dns_enabled
  jenkins_x_namespace             = module.cluster.jenkins_x_namespace
  kubelet_identity_id             = module.cluster.kubelet_identity_id
  subscription_id                 = data.azurerm_client_config.current.subscription_id
  tenant_id                       = local.tenant_id
  is_jx2                          = var.is_jx2
  apex_domain_integration_enabled = var.apex_domain_integration_enabled
}

// ----------------------------------------------------------------------------
// Setup Azure Container Registry (if enabled)
// ----------------------------------------------------------------------------
module "registry" {
  source                  = "./modules/registry"
  location                = var.location
  resource_group          = azurerm_resource_group.registry.name
  container_registry_name = local.container_registry_name
  kubelet_identity_id     = module.cluster.kubelet_identity_id
}

// ----------------------------------------------------------------------------
// Setup Secret Storage dependencies in Azure
// ----------------------------------------------------------------------------
module "secretstorage" {
  source                       = "./modules/secretstorage"
  cluster_id                   = local.cluster_id
  cluster_name                 = local.cluster_name
  enable_native                = var.secret_management.enable_native
  enable_workload_identity     = var.enable_workload_identity
  identity_resource_group_name = local.identity_resource_group_name
  kubelet_identity_id          = module.cluster.kubelet_identity_id
  location                     = var.location
  resource_group_name          = azurerm_resource_group.secrets.name
  storage_account_regex        = local.alphanum_regex
  tenant_id                    = local.tenant_id
}

// ----------------------------------------------------------------------------
// Setup Workload Identity for AKS (a.k.a. Azure AD Pod Identity)
// ----------------------------------------------------------------------------

module "workload_identity" {
  source                      = "./modules/workloadidentity"
  enable                      = var.enable_workload_identity
  kubelet_identity_id         = module.cluster.kubelet_identity_id
  cluster_node_resource_group = module.cluster.node_resource_group
  identities                  = local.identities
}

// ----------------------------------------------------------------------------
// Let's generate jx-requirements.yml 
// ----------------------------------------------------------------------------
locals {
  interpolated_content = templatefile("${path.module}/modules/jx-requirements.yml.tpl", {
    cluster_name                = local.cluster_name
    git_owner_requirement_repos = var.git_owner_requirement_repos
    dev_env_approvers           = var.dev_env_approvers

    // External DNS
    enable_external_dns  = var.external_dns_enabled
    domain               = module.dns.domain
    ignore_load_balancer = var.external_dns_enabled
    dns_tenant_id        = module.dns.tenant_id
    dns_subscription_id  = module.dns.subscription_id
    dns_resource_group   = module.dns.resource_group_name

    // TLS
    enable_tls                 = var.tls.enable
    tls_email                  = var.tls.email
    use_production_letsencrypt = var.lets_encrypt_production

    // Velero
    enable_backup                         = var.enable_backup
    velero_storage_account                = var.enable_backup ? module.backup.velero_storage_account : ""
    velero_namespace                      = var.enable_backup ? var.velero_namespace : ""
    velero_schedule                       = var.velero_schedule
    velero_ttl                            = var.velero_ttl
    velero_bucket_name                    = module.backup.velero_container_name
    velero_storage_account_resource_group = module.cluster.node_resource_group
    backup_container_url                  = module.backup.backup_container_url

    // Container Registry
    registry_name = "${local.container_registry_name}.azurecr.io"

    // Vault
    enable_vault                 = ! var.secret_management.enable_native
    vault_tenant_id              = local.tenant_id
    vault_keyvault_name          = module.secretstorage.keyvault_name
    vault_key_name               = module.secretstorage.key_name
    vault_storage_account_name   = module.secretstorage.storage_account_name
    vault_storage_container_name = module.secretstorage.storage_container_name

    version_stream_ref = var.version_stream_ref
    version_stream_url = local.version_stream_url
    webhook            = var.webhook
  })

  split_content   = split("\n", local.interpolated_content)
  compact_content = compact(local.split_content)
  content         = join("\n", local.compact_content)
}
