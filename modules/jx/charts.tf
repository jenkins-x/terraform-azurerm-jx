resource "helm_release" "jx-git-operator" {
  count            = var.enabled ? 1 : 0
  name             = "jx-git-operator"
  chart            = "jx-git-operator"
  namespace        = "jx-git-operator"
  repository       = "https://jenkins-x-charts.github.io/repo"
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

module "jx-health" {
  count  = var.enabled ? 1 : 0
  source = "github.com/jenkins-x/terraform-jx-health?ref=main"

  depends_on = [
    var.kubernetes_cluster
  ]
}
