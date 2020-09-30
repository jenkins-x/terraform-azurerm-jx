
// ----------------------------------------------------------------------------
// Add the Terraform generated jx-requirements.yml to a configmap so it can be
// sync'd with the Git repository
//
// ----------------------------------------------------------------------------
resource "kubernetes_config_map" "jenkins_x_requirements" {
  count = var.is_jx2 ? 0 : 1
  metadata {
    name      = "terraform-jx-requirements"
    namespace = "default"
  }
  data = {
    "jx-requirements.yml" = local.content
  }

  lifecycle {
    ignore_changes = [
      metadata,
      data
    ]
  }
  depends_on = [
    module.cluster
  ]
}

// ----------------------------------------------------------------------------
// Add in post-process secret so it can be executed by boot process to
// sync secrets between terraform and jx
//
// ----------------------------------------------------------------------------
resource "kubernetes_secret" "jx-post-process" {
  count = ! var.is_jx2 && var.secret_management.enable_native ? 1 : 0

  metadata {
    name      = "jx-post-process"
    namespace = "default"
  }

  data = {
    commands : <<EOF
kubectl create secret -n ${local.secret_infra_namespace} ${local.kubernetes_external_secret_name} --from-literal=clientSecret=${module.key_vault.key_vault_client_secret} --from-literal=clientId=${module.key_vault.key_vault_client_id} --from-literal=tenantId=${local.tenant_id}
EOF
  }

  lifecycle {
    ignore_changes = [
      metadata,
      data
    ]
  }
  depends_on = [
    module.cluster
  ]
}
