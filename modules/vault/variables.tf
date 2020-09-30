variable "enable_vault" {
  type = bool
}
variable "cluster_name" {
  type = string
}
variable "cluster_id" {
  type = string
}
variable "resource_group" {
  type = string
}
variable "location" {
  type = string
}
variable "tenant_id" {
  description = "Tenant Id of the Azure AD domain resources are being created in"
  type        = string
}
variable "kubelet_identity_id" {
  description = "Kubelet managed identity id"
  type        = string
}
variable "storage_account_regex" {
  description = "Regex expression to sanitise a storage account name"
}
variable "identity_resource_group_name" {
  type = string
}
variable "secret_infra_namespace" {
  type = string
}
variable "enable_workload_identity" {
  type = bool
}
