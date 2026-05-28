# Bootstrap — Terraform state backend

This module creates the resources needed to store Terraform state remotely:

- An S3 bucket (`brianmuteti-tfstate`) — versioned, encrypted, public-access blocked
- A DynamoDB table (`brianmuteti-tflock`) — pay-per-request, for state locking

Everything in [`../main`](../main) (S3 site bucket, CloudFront, ACM, Route 53,
GitHub OIDC) uses these resources as its state backend.

## Why this is a separate module

There is a chicken-and-egg problem with managing Terraform state in S3:
the state bucket cannot itself be managed by Terraform that uses that bucket
as its backend. The bootstrap module is therefore a tiny one-off configuration
that uses local state to create just the state backend. Its own state file
(`terraform.tfstate`) is committed to Git so the backend itself can be
modified later if needed.

This is the standard pattern.

## Usage

This module is applied **once, ever**:

```bash
cd infra/bootstrap
terraform init
terraform plan
terraform apply
```

After this, all other Terraform in this repo uses the S3 backend created here.

## Cost

- S3 storage of the state file: a few cents per month
- DynamoDB pay-per-request: effectively zero at this usage level