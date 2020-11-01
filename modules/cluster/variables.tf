variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  description = "Kubernetes version to use for the AKS cluster."
  type        = string
}
variable "location" {
  type = string
}
variable "node_size" {
  type = string
}
variable "node_count" {
  type = string
}
variable "vnet_subnet_id" {
  type = string
}
variable "dns_prefix" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "node_resource_group_name" {
  type = string
}
variable "network_resource_group" {
  type = string
}
variable "jenkins_x_namespace" {
  type = string
}
variable "cluster_network_model" {
  type    = string
  default = "kubenet"
}
variable "is_jx2" {
  type = bool
}
variable "jx_git_url" {
  type = string
}
variable "jx_bot_username" {
  type = string
}
variable "jx_bot_token" {
  type = string
}
variable "secrets_infra_namespace" {
  type = string
}
variable "enable_log_analytics" {
  type = bool
}
variable "logging_retention_days" {
  type = number
}
