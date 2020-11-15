variable "kubelet_identity_id" {
  type = string
}
variable "cluster_node_resource_group" {
  type = string
}
variable "enable" {
  type = bool
}
variable "identities" {
  type = list(object({
    name       = string
    resourceId = string
    clientId   = string
    binding = object({
      name     = string
      selector = string
    })
  }))
}
