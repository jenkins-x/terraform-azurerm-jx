variable "cluster_name" {
  type    = string
  default = ""
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
  type    = string
  default = ""
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
  type    = string
  default = ""
}
variable "cluster_resource_group" {
  type    = string
  default = ""
}
variable "dns_resource_group" {
  type    = string
  default = ""
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
  type    = string
  default = ""
}
variable "cluster_network_model" {
  type    = string
  default = "kubenet"
}
variable "subnet_name" {
  type    = string
  default = ""
}
variable "jenkins_x_namespace" {
  type    = string
  default = "jx"
}

// ----------------------------------------------------------------------------
// TLS
// ----------------------------------------------------------------------------

variable "tls" {
  type = object({
    enable = string,
    email  = string,
  })

  description = "enable - Flag to enable TLS in the final `jx-requirements.yml` file. email - The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"

  default = {
    enable = false
    email  = ""
  }

  validation {
    condition = (
      (var.tls.enable && length(var.tls.email) > 0)
      || ! var.tls.enable
    )
    error_message = "If TLS is enabled then var.tls.email must be specified."
  }

}

// ----------------------------------------------------------------------------
// External DNS
// ----------------------------------------------------------------------------
variable "apex_domain_resource_group_name" {
  type    = string
  default = ""
}
variable "apex_domain" {
  type    = string
  default = ""
}
variable "domain_name" {
  type    = string
  default = ""
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
  default     = ""
}
variable "registry_resource_group" {
  description = "Name of resource group (to provision) in which to create registry"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// Vault
// ----------------------------------------------------------------------------
variable "vault_url" {
  description = "URL to an external Vault instance in case Jenkins X shall not create its own system Vault"
  type        = string
  default     = ""
}
variable "vault_resource_group" {
  description = "Resource group to create for Vault resources"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// jx-requirements.yml specific variables only used for template rendering
// ----------------------------------------------------------------------------
variable "git_owner_requirement_repos" {
  description = "The git id of the owner for the requirement repositories"
  type        = string
  default     = ""
}

variable "dev_env_approvers" {
  description = "List of git users allowed to approve pull request for dev environment repository"
  type        = list(string)
  default     = []
}

variable "lets_encrypt_production" {
  description = "Flag to determine whether or not to use the Let's Encrypt production server."
  type        = bool
  default     = true
}

variable "webhook" {
  description = "Jenkins X webhook handler for git provider"
  type        = string
  default     = "lighthouse"
}

variable "version_stream_url" {
  description = "The URL for the version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/"
  type        = string
  default     = "https://github.com/jenkins-x/jenkins-x-versions.git"
}

variable "version_stream_ref" {
  description = "The git ref for version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/"
  type        = string
  default     = "master"
}
