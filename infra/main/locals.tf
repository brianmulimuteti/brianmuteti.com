locals {
  common_tags = {
    Project   = "brianmuteti.com"
    Module    = "main"
    ManagedBy = "Terraform"
    Owner     = "Brian Muli Muteti"
  }

  apex_domain = var.domain_name
  www_domain  = "www.${var.domain_name}"

  # The set of names the certificate must cover.
  cert_domain_names = [
    local.apex_domain,
    local.www_domain,
  ]
}
