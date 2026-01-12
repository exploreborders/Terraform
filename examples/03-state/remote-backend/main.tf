# Terraform Backend Configuration
terraform {
  backend "s3" {
    bucket         = var.state_bucket_name
    key            = "examples/state/remote-backend/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.lock_table_name
    encrypt        = true
  }
}

# AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Simple S3 bucket for demonstration
resource "aws_s3_bucket" "example" {
  bucket = var.example_bucket_name

  tags = {
    Name        = var.example_bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "State Management Demo"
  }
}

# Enable versioning on the example bucket
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket for state storage (if not created by setup script)
resource "aws_s3_bucket" "state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = var.state_bucket_name

  tags = {
    Name        = var.state_bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Terraform State Storage"
  }
}

# Enable versioning on state bucket
resource "aws_s3_bucket_versioning" "state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for state locking (if not created by setup script)
resource "aws_dynamodb_table" "state_lock" {
  count        = var.create_lock_table ? 1 : 0
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.lock_table_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Terraform State Locking"
  }
}