terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote State — S3 + DynamoDB locking
  # ---------------------------------------------------------------------------
  # IMPORTANT: The S3 bucket and DynamoDB table must be created BEFORE running
  # `terraform init`. Use the bootstrap script in this folder or create them
  # manually:
  #
  #   aws s3api create-bucket \
  #     --bucket expense-tracker-tfstate \
  #     --region ap-southeast-2
  #
  #   aws s3api put-bucket-versioning \
  #     --bucket expense-tracker-tfstate \
  #     --versioning-configuration Status=Enabled
  #
  #   aws s3api put-bucket-encryption \
  #     --bucket expense-tracker-tfstate \
  #     --server-side-encryption-configuration \
  #       '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
  #
  # NOTE: DynamoDB locking is deprecated in Terraform >= 1.10.
  #       Native S3 locking (use_lockfile = true) is used instead.
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
  # Remote State — uncomment once IAM permissions on the S3 bucket are granted
  # (s3:GetObject, s3:PutObject, s3:ListBucket on expense-tracker-tfstate)
  # ---------------------------------------------------------------------------
  backend "s3" {
    bucket       = "expense-tracker-tfstate-pb842"
    key          = "aws/expense-tracker/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # replaces deprecated dynamodb_table param
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "expense-tracker"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
