# Main infrastructure — brianmuteti.com

Production infrastructure for [brianmuteti.com](https://brianmuteti.com).
All state lives in S3 (`brianmuteti-tfstate/main/terraform.tfstate`) with
DynamoDB-backed locking; see [`../bootstrap`](../bootstrap) for the backend.

## What this creates

| Resource | Purpose |
|---|---|
| `aws_s3_bucket.site` | Private bucket holding built site assets |
| `aws_cloudfront_distribution.site` | CDN + HTTPS for apex (canonical) |
| `aws_cloudfront_distribution.www_redirect` | 301 redirect from www to apex |
| `aws_cloudfront_function.www_redirect` | The redirect logic (CF Function, not Lambda@Edge) |
| `aws_acm_certificate.site` | TLS cert for apex + www, DNS-validated in us-east-1 |
| `aws_route53_record.{apex,www}` | DNS records pointing both names at CloudFront |
| `aws_iam_openid_connect_provider.github` | OIDC trust for GitHub Actions |
| `aws_iam_role.github_deploy` | Role GitHub Actions assumes; least-privilege deploy |

## Architecture decisions

**Private S3, OAC-restricted access.** The site bucket has all public access
blocked; CloudFront reads through an Origin Access Control identity authenticated
with SigV4. This is the modern replacement for Origin Access Identity (OAI).

**Apex canonical, www redirects.** Visitors typing `www.brianmuteti.com` get
a 301 to the apex domain, executed at the edge by a CloudFront Function — no
origin fetch, no Lambda@Edge cold starts. SEO-friendly, single-source-of-truth.

**OIDC for CI/CD.** GitHub Actions assumes an IAM role via OpenID Connect.
No long-lived AWS access keys are stored in GitHub Secrets. The trust policy
restricts assumption to this exact repo + the `main` branch.

**Least-privilege deploy role.** The deploy role can sync to the site bucket
and invalidate the main CloudFront distribution. Nothing else.

**ACM cert in us-east-1.** CloudFront only reads ACM certs from us-east-1
regardless of where the origin is. An aliased provider documents this dependency.

## Usage

```bash
cd infra/main

# First time
terraform init

# Whenever you change something
terraform plan
terraform apply
```

The first apply takes 5–15 minutes. Most of that is CloudFront propagation.

## Cost

At portfolio traffic levels (~thousands of requests/month), expected monthly
cost is approximately **\$1.50–3.00 USD**:

- Route 53 hosted zone: \$0.50
- S3 storage + requests: cents
- CloudFront: cents (free tier covers significant traffic)
- ACM cert: free
- DynamoDB state lock: cents

## How deploys reach this infrastructure

The deploy workflow lives at [`/.github/workflows/deploy.yml`](../../.github/workflows/deploy.yml).
It runs on every push to `main` and can also be triggered manually from
the Actions tab. The workflow:

1. Builds the Astro site (`npm run build`)
2. Assumes the `github-deploy-brianmuteti-com` role via OIDC — no static
   AWS credentials anywhere
3. Syncs the build output to S3 with split cache headers:
   - immutable assets (CSS, JS, images): 1-year cache
   - HTML: no cache, revalidate every request
4. Creates a CloudFront invalidation on `/*` so the new content is served
   immediately

End-to-end deploy time: ~2–3 minutes.
