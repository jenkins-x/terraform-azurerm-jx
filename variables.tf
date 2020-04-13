variable "resource_group_name" {
  type    = string
  default = "aks-rg"
}

variable "resource_group_location" {
  type    = string
  default = "East US"
}

variable "cluster_name" {
  type    = string
  default = "akscluster"
}

variable "dns_prefix" {
  description = "(Required) DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created."
  type        = string
}

variable "service_principal_id" {
  type = string
}

variable "service_principal_secret" {
  type = string
}

variable "node_count" {
  type    = string
  default = "1"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "kubernetes_version" {
  default = "1.15.7"
  type    = string
}

variable "admin_user" {
  type    = string
  default = "aksadmin"
}

variable "ssh_public_key" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "(Required) The SSH public key used to setup log-in credentials on the nodes in the AKS cluster."
}

variable "address_space" {
  type        = list
  description = "The address space that is used by the virtual network."
  default     = ["10.10.0.0/16"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list
  default     = ["akssubnet"]
}

variable "subnet_prefixes" {
  type        = string
  description = "The address prefix to use for the subnet."
  default     = "10.10.1.0/24"
}


variable "network_plugin" {
  type        = string
  default     = "azure"
  description = "Network plugin used by AKS. Either azure or kubenet."
}
variable "network_policy" {
  type        = string
  default     = "azure"
  description = "Network policy to be used with Azure CNI. Either azure or calico."
}

variable "targeted_environment" {
  type        = string
  default     = "Development"
  description = "(Optional) A mapping of tags to assign to the resource."

}
