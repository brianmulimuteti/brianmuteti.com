output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for the main site (used by deploy workflow for invalidations)"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_distribution_domain" {
  description = "CloudFront domain for the main site (debugging aid)"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "www_cloudfront_distribution_id" {
  description = "CloudFront distribution ID for the www redirect"
  value       = aws_cloudfront_distribution.www_redirect.id
}

output "site_bucket_name" {
  description = "S3 bucket holding the built site"
  value       = aws_s3_bucket.site.id
}

output "site_bucket_arn" {
  description = "ARN of the site bucket"
  value       = aws_s3_bucket.site.arn
}

output "github_deploy_role_arn" {
  description = "IAM role ARN that GitHub Actions assumes via OIDC"
  value       = aws_iam_role.github_deploy.arn
}

output "route53_zone_id" {
  description = "Hosted zone the site DNS records live in"
  value       = data.aws_route53_zone.site.zone_id
}
