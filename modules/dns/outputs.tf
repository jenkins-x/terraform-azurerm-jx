output "domain" {
  value = var.enabled ? trimprefix(join(".", [var.domain_name, var.apex_domain]), ".") : ""
}
