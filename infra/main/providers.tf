provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

# CloudFront requires its ACM certs to live in us-east-1.
# Aliased provider used by acm.tf for that purpose.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
