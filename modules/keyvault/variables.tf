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
variable "enable_keyvault" {
  type = bool
}
variable "cluster_id" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "key_vault_regex" {
  type = string
}
