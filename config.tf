
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
    ]
  }
  depends_on = [
    module.cluster
  ]
}

locals {
  secrets         = []
  create_secret   = false
  compact_secrets = compact(local.secrets)
}

// ----------------------------------------------------------------------------
// Add in post-process secret so it can be executed by boot process to
// sync secrets between terraform and jx
//
// ----------------------------------------------------------------------------
resource "kubernetes_secret" "jx-post-process" {
  count = ! var.is_jx2 && local.create_secret ? 1 : 0

  metadata {
    name      = "jx-post-process"
    namespace = "default"
  }

  data = {
    commands : join("\n", local.compact_secrets)
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  depends_on = [
    module.cluster
  ]
}
