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
