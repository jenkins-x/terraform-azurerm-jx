// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "cluster_id" {
  description = "A random generated to uniquely name cluster resources"
  type        = string
}

variable "resource_group" {
  description = "Resource group in which to create storage for backups"
  type        = string
}

variable "location" {
  description = "Location of the resource group in which to create backups"
  type        = string
}

variable "tenant_id" {
  description = "Tenant Id of the Azure AD domain resources are being created in"
  type        = string
}

variable "subscription_id" {
  description = "Subscription Id in which Azure resources are being created"
  type        = string
}

variable "storage_account_regex" {
  description = "Regex expression to sanitise a storage account name"
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "enable_backup" {
  description = "Whether or not Velero backups should be enabled"
  type        = bool
  default     = false
}
variable "velero_namespace" {
  description = "Kubernetes namespace for Velero"
  type        = string
  default     = "velero"
}
