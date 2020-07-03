resource "random_pet" "cluster" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    cluster_name = var.cluster_name
  }
}

resource "random_pet" "dns_prefix" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    dns_prefix = var.dns_prefix
  }
}

resource "random_pet" "network_resource_group" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    network_resource_group = var.network_resource_group
  }
}

resource "random_pet" "cluster_resource_group" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    cluster_resource_group = var.cluster_resource_group
  }
}

resource "random_pet" "network_name" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    network_name = var.network_name
  }
}

resource "random_pet" "subnet_name" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    subnet_name = var.subnet_name
  }
}

resource "random_pet" "dns_resource_group" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    dns_resource_group = var.dns_resource_group
  }
}

resource "random_pet" "domain_name" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    domain_name = var.domain_name
  }
}

resource "random_pet" "msi_name" {
  prefix    = "msi-aks"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    msi_name = var.msi_name
  }
}

locals {
  cluster_name           = var.cluster_name != "" ? var.cluster_name : random_pet.cluster.id
  node_count             = var.node_count != "" ? var.node_count : 1
  node_size              = var.node_size != "" ? var.node_size : "Standard_B2ms"
  dns_prefix             = var.dns_prefix != "" ? var.dns_prefix : random_pet.dns_prefix.id
  cluster_version        = var.cluster_version != "" ? var.cluster_version : "1.15.11"
  location               = var.location != "" ? var.location : "australiaeast"
  network_resource_group = var.network_resource_group != "" ? var.network_resource_group : random_pet.network_resource_group.id
  cluster_resource_group = var.cluster_resource_group != "" ? var.cluster_resource_group : random_pet.cluster_resource_group.id
  vnet_cidr              = var.vnet_cidr != "" ? var.vnet_cidr : "10.8.0.0/16"
  subnet_cidr            = var.subnet_cidr != "" ? var.subnet_cidr : "10.8.0.0/24"
  network_name           = var.network_name != "" ? var.network_name : random_pet.network_name.id
  subnet_name            = var.subnet_name != "" ? var.subnet_name : random_pet.subnet_name.id
  dns_resource_group     = var.dns_resource_group != "" ? var.dns_resource_group : random_pet.dns_resource_group.id
  domain_name            = var.domain_name != "" ? var.domain_name : random_pet.domain_name.id
  msi_name               = var.msi_name != "" ? var.msi_name : random_pet.msi_name.id
}
