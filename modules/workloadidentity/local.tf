locals {
  workload_identity_namespace = "workload-identity"
  identityTransform = [for o in var.identities :
    <<EOF
- name: ${o.name}
  type: 0
  namespace: ${o.namespace}
  resourceID: ${o.resourceId}
  clientID: ${o.clientId}
  binding:
    name: ${o.binding.name}
    selector: ${o.binding.selector}
EOF
  ]
  azureIdentities = "azureIdentities:\n${join("", local.identityTransform)}"
}
