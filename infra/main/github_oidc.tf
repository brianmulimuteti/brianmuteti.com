# ============================================================
# GitHub Actions OIDC
# Allows the deploy workflow in this repo (and only this repo)
# to assume an IAM role and deploy to S3 + invalidate CloudFront,
# without any long-lived AWS access keys in GitHub secrets.
# ============================================================

# OIDC provider trust for token.actions.githubusercontent.com.
# Thumbprint is the well-known GitHub Actions OIDC root CA fingerprint.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restricts which GitHub repo + branch can assume this role.
    # Only pushes to main on this specific repo can deploy.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main",
      ]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "github-deploy-${replace(var.domain_name, ".", "-")}"
  description        = "Assumed by GitHub Actions to deploy ${var.domain_name}"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
  max_session_duration = 3600
}

# Permissions: sync to the site bucket and invalidate CloudFront.
# Nothing else.
data "aws_iam_policy_document" "github_deploy" {
  statement {
    sid = "SiteBucketSync"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      aws_s3_bucket.site.arn,
      "${aws_s3_bucket.site.arn}/*",
    ]
  }

  statement {
    sid       = "CloudFrontInvalidate"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.site.arn]
  }
}

resource "aws_iam_role_policy" "github_deploy" {
  name   = "github-deploy-${replace(var.domain_name, ".", "-")}"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deploy.json
}
