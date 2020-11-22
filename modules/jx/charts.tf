resource "helm_release" "jx-git-operator" {
  count            = var.enabled ? 1 : 0
  name             = "jx-git-operator"
  chart            = "jx-git-operator"
  namespace        = "jx-git-operator"
  repository       = "https://storage.googleapis.com/jenkinsxio/charts"
  create_namespace = true

  set {
    name  = "bootServiceAccount.enabled"
    value = true
  }
  set {
    name  = "env.NO_RESOURCE_APPLY"
    value = true
  }
  set {
    name  = "url"
    value = var.jx_git_url
  }
  set {
    name  = "username"
    value = var.jx_bot_username
  }
  set_sensitive {
    name  = "password"
    value = var.jx_bot_token
  }

  lifecycle {
    ignore_changes = all
  }
  depends_on = [
    var.kubernetes_cluster
  ]
}

locals {
  tf_drift_secret_map = {
    "ARM_SUBSCRIPTION_ID" : var.subscription_id,
    "ARM_TENANT_ID" : var.tenant_id,
    "ARM_CLIENT_ID" : var.jx_health_client_id,
    "ARM_CLIENT_SECRET" : var.jx_health_client_secret,
  }
}

module "jx-health" {
  count               = var.enabled ? 1 : 0
  source              = "github.com/jenkins-x/terraform-jx-health?ref=main"
  jx_git_url          = var.jx_git_url
  jx_bot_username     = var.jx_bot_username
  jx_bot_token        = var.jx_bot_token
  tf_drift_secret_map = local.tf_drift_secret_map

  depends_on = [
    var.kubernetes_cluster
  ]
}
