# ============================================================
# Route 53
# Hosted zone already exists (created when the domain was
# registered via Route 53). We look it up by name and add
# records to it; we never recreate the zone.
# ============================================================

data "aws_route53_zone" "site" {
  name         = var.domain_name
  private_zone = false
}

# Apex — brianmuteti.com → CloudFront
resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = local.apex_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

# www — www.brianmuteti.com → the redirect distribution
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = local.www_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.www_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}
