// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// ----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.25"
}

// ----------------------------------------------------------------------------
// Configure providers
// ----------------------------------------------------------------------------
provider "azurerm" {
  version = ">= 2.15.0"
  features {}
}

provider "kubernetes" {
  version          = ">= 1.11.0"
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

// ----------------------------------------------------------------------------
// Setup Azure Resource Groups
// ----------------------------------------------------------------------------

resource "azurerm_resource_group" "network" {
  name     = local.network_resource_group
  location = var.location
}

resource "azurerm_resource_group" "cluster" {
  name     = local.cluster_resource_group
  location = var.location
}

resource "azurerm_resource_group" "dns" {
  count    = var.external_dns_enabled ? 1 : 0
  name     = local.dns_resource_group
  location = var.location
}


// ----------------------------------------------------------------------------
// Setup Azure Cluster
// ----------------------------------------------------------------------------

module "cluster" {
  source                 = "./modules/cluster"
  cluster_name           = local.cluster_name
  node_count             = var.node_count
  node_size              = var.node_size
  vnet_subnet_id         = module.vnet.subnet_id
  dns_prefix             = local.dns_prefix
  cluster_version        = var.cluster_version
  location               = var.location
  resource_group_name    = azurerm_resource_group.cluster.name
  network_resource_group = local.network_resource_group
  jenkins_x_namespace    = var.jenkins_x_namespace
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
// Setup Azure DNS (if enabled)
// ----------------------------------------------------------------------------

module "dns" {
  source                   = "./modules/dns"
  resource_group_name      = azurerm_resource_group.dns[0].name
  apex_resource_group_name = var.apex_domain_resource_group_name
  apex_domain              = var.apex_domain
  domain_name              = local.domain_name
  enabled                  = var.external_dns_enabled
}


// ----------------------------------------------------------------------------
// Let's generate jx-requirements.yml 
// ----------------------------------------------------------------------------
resource "local_file" "jx-requirements" {
  depends_on = [
    module.cluster
  ]
  content = templatefile("${path.module}/jx-requirements.yml.tpl", {
    cluster_name               = local.cluster_name
    enable_external_dns        = var.external_dns_enabled
    domain                     = module.dns.domain
    enable_tls                 = var.enable_tls
    tls_email                  = var.tls_email
    use_production_letsencrypt = var.production_letsencrypt
  })
  filename = "${path.cwd}/jx-requirements.yml"
}
