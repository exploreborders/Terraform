# Security Implementation

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

# Encrypted S3 bucket for secure storage
resource "aws_s3_bucket" "secure_storage" {
  bucket = var.secure_bucket_name

  tags = {
    Name        = var.secure_bucket_name
    Environment = var.environment
    Purpose     = "Secure Storage"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for recovery
resource "aws_s3_bucket_versioning" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudTrail for audit logging
resource "aws_cloudtrail" "security_trail" {
  name                          = "security-trail"
  s3_bucket_name                = aws_s3_bucket.secure_storage.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = {
    Name        = "security-trail"
    Environment = var.environment
    Purpose     = "Security Auditing"
    ManagedBy   = "Terraform"
  }
}

# KMS key for encryption
resource "aws_kms_key" "security_key" {
  description             = "KMS key for security operations"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "security-key"
    Environment = var.environment
    Purpose     = "Encryption"
    ManagedBy   = "Terraform"
  }
}

# IAM role with least privilege
resource "aws_iam_role" "security_role" {
  name = "security-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.account_id}:root"
      }
      Condition = {
        Bool = {
          "aws:MultiFactorAuthPresent" = "true"
        }
      }
    }]
  })

  tags = {
    Name        = "security-role"
    Environment = var.environment
    Purpose     = "Security Monitoring"
    ManagedBy   = "Terraform"
  }
}

# Attach security audit policy
resource "aws_iam_role_policy_attachment" "security_audit" {
  role       = aws_iam_role.security_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# Config rule for S3 encryption
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  tags = {
    Name        = "s3-encryption-rule"
    Environment = var.environment
    Purpose     = "Compliance"
    ManagedBy   = "Terraform"
  }
}

# Security group with least privilege
resource "aws_security_group" "secure_sg" {
  name_prefix = "secure-sg-"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "secure-sg"
    Environment = var.environment
    Purpose     = "Network Security"
    ManagedBy   = "Terraform"
  }
}

# Secrets Manager for secure credential storage
resource "aws_secretsmanager_secret" "app_credentials" {
  name                    = "app/credentials"
  description             = "Application credentials"
  kms_key_id              = aws_kms_key.security_key.id
  recovery_window_in_days = 30

  tags = {
    Name        = "app-credentials"
    Environment = var.environment
    Purpose     = "Secret Storage"
    ManagedBy   = "Terraform"
  }
}

# Example secret version
resource "aws_secretsmanager_secret_version" "app_credentials" {
  secret_id = aws_secretsmanager_secret.app_credentials.id
  secret_string = jsonencode({
    username = "app_user"
    password = "secure_password_here" # In practice, use random generation
  })
}