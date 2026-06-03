variable "region" {
  description = "AWS region for the site bucket and CloudFront origin"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Apex domain for the site (canonical)"
  type        = string
  default     = "brianmuteti.com"
}

variable "site_bucket_name" {
  description = "Name of the S3 bucket that holds built site assets"
  type        = string
  default     = "brianmuteti-site"
}

variable "github_owner" {
  description = "GitHub user or organization that owns the deploying repository"
  type        = string
  default     = "brianmulimuteti"
}

variable "github_repo" {
  description = "GitHub repository name allowed to deploy via OIDC"
  type        = string
  default     = "brianmuteti.com"
}

variable "default_root_object" {
  description = "Document CloudFront serves when a request hits the root of the distribution"
  type        = string
  default     = "index.html"
}
