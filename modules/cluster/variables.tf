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
variable "network_resource_group" {
  type = string
}
variable "msi_name" {
  type = string
}
variable "aad_pod_id_ns" {
  type    = string
  default = "aad-pod-id"
}
variable "aad_pod_id_binding_selector" {
  type    = string
  default = "aad-pod-id-binding-selector"
}
variable "jenkins_x_namespace" {
  type = string
}
