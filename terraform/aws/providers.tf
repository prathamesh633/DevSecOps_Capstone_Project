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
  #     --region us-east-1
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
  #   aws dynamodb create-table \
  #     --table-name expense-tracker-tfstate-lock \
  #     --attribute-definitions AttributeName=LockID,AttributeType=S \
  #     --key-schema AttributeName=LockID,KeyType=HASH \
  #     --billing-mode PAY_PER_REQUEST \
  #     --region us-east-1
  # ---------------------------------------------------------------------------
  backend "s3" {
    bucket         = "expense-tracker-tfstate"
    key            = "aws/expense-tracker/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "expense-tracker-tfstate-lock"
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
