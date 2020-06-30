variable "cluster_name" {
  type = string
}
variable "node_count" {
  type = string
}
variable "node_size" {
  type = string
}
variable "dns_prefix" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "location" {
  type = string
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
  type = string
}
variable "subnet_cidr" {
  type = string
}
variable "network_name" {
  type = string
}
variable "subnet_name" {
  type = string
}
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
