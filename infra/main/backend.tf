terraform {
  backend "s3" {
    bucket         = "brianmuteti-tfstate"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "brianmuteti-tflock"
    encrypt        = true
  }
}
