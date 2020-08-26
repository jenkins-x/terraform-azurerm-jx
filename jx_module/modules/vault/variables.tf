variable "external_vault" {
  type = string
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
