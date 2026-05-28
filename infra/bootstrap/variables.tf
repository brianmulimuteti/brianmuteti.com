variable "region" {
  description = "AWS region for the Terraform state backend"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state"
  type        = string
  default     = "brianmuteti-tfstate"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "brianmuteti-tflock"
}
