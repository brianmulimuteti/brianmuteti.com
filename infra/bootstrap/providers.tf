provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "brianmuteti.com"
      Module    = "bootstrap"
      ManagedBy = "Terraform"
      Owner     = "Brian Muli Muteti"
    }
  }
}
