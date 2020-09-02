output "domain" {
  value = trimprefix(join(".", [var.domain_name, var.apex_domain]), ".")
}
