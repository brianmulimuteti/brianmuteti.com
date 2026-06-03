# ============================================================
# CloudFront — main distribution
# Serves the apex domain (brianmuteti.com) from the S3 origin.
# ============================================================

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.site_bucket_name}-oac"
  description                       = "Origin Access Control for ${var.site_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  comment             = "brianmuteti.com — apex (canonical)"
  price_class         = "PriceClass_100" # US, Canada, Europe (cheapest tier)

  aliases = [local.apex_domain]

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${aws_s3_bucket.site.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${aws_s3_bucket.site.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # AWS managed cache policy "CachingOptimized"
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # Astro's 404.html lives at /404.html in the built output.
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  http_version = "http2and3"
}

# ============================================================
# CloudFront Function — www -> apex 301 redirect
# Runs at viewer-request on the www distribution.
# ============================================================

resource "aws_cloudfront_function" "www_redirect" {
  name    = "${replace(var.domain_name, ".", "-")}-www-to-apex"
  runtime = "cloudfront-js-2.0"
  comment = "301 redirect from www.${var.domain_name} to ${var.domain_name}"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var host = request.headers.host ? request.headers.host.value : '';
      var location = 'https://${var.domain_name}' + request.uri;
      if (request.querystring && Object.keys(request.querystring).length > 0) {
        var qs = [];
        for (var k in request.querystring) {
          var v = request.querystring[k];
          if (v.multiValue) {
            for (var i = 0; i < v.multiValue.length; i++) {
              qs.push(encodeURIComponent(k) + '=' + encodeURIComponent(v.multiValue[i].value));
            }
          } else {
            qs.push(encodeURIComponent(k) + '=' + encodeURIComponent(v.value));
          }
        }
        if (qs.length > 0) location += '?' + qs.join('&');
      }
      return {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: { 'location': { value: location } }
      };
    }
  EOT
}

# ============================================================
# CloudFront — www redirect distribution
# Catches all traffic on www.brianmuteti.com and 301s it
# to the apex. Has its own minimal origin (the same S3 bucket)
# but the function returns before any origin fetch happens.
# ============================================================

resource "aws_cloudfront_distribution" "www_redirect" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "brianmuteti.com — www -> apex redirect"
  price_class     = "PriceClass_100"

  aliases = [local.www_domain]

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${aws_s3_bucket.site.id}-redirect"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${aws_s3_bucket.site.id}-redirect"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # CachingDisabled — we don't want CDN-cached redirects with
    # mismatched paths between users.
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.www_redirect.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  http_version = "http2and3"
}
