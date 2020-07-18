variable "cluster_name" {
  type = string
}
variable "node_count" {
  type    = number
  default = 1
}
variable "node_size" {
  type    = string
  default = "Standard_B2ms"
}
variable "dns_prefix" {
  type = string
}
variable "cluster_version" {
  type    = string
  default = "1.15.11"
}
variable "location" {
  type    = string
  default = "australiaeast"
}
variable "network_resource_group" {
  type = string
}
variable "cluster_resource_group" {
  type = string
}
variable "dns_resource_group" {
  type = string
}
variable "vnet_cidr" {
  type    = string
  default = "10.8.0.0/16"
}
variable "subnet_cidr" {
  type    = string
  default = "10.8.0.0/24"
}
variable "network_name" {
  type = string
}
variable "subnet_name" {
  type = string
}
variable "tls_email" {
  description = "The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"
  type        = string
  default     = ""
}
variable "enable_tls" {
  description = "Flag to enable TLS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}
variable "production_letsencrypt" {
  description = "Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file"
  type        = bool
  default     = false
}
variable "jenkins_x_namespace" {
  type    = string
  default = "jx"
}

// ----------------------------------------------------------------------------
// External DNS
// ----------------------------------------------------------------------------
variable "apex_domain_resource_group_name" {
  type = string
}
variable "apex_domain" {
  type = string
}
variable "domain_name" {
  type = string
}
variable "external_dns_enabled" {
  type    = bool
  default = false
}

// ----------------------------------------------------------------------------
// Velero/backup
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

variable "velero_schedule" {
  description = "The Velero backup schedule in cron notation to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml))"
  type        = string
  default     = "0 * * * *"
}

variable "velero_ttl" {
  description = "The the lifetime of a velero backup to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup))"
  type        = string
  default     = "720h0m0s"
}


// ----------------------------------------------------------------------------
// Container Registry
// ----------------------------------------------------------------------------
variable "create_registry" {
  description = "Flag to indicate whether a container registry should be created"
  type        = bool
  default     = false
}
variable "container_registry_name" {
  description = "Name of container registry"
  type        = string
}
variable "registry_resource_group" {
  description = "Name of resource group (to provision) in which to create registry"
  type        = string
}
