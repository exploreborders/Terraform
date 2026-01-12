# Security Best Practices Implementation

This example demonstrates implementing security best practices in Terraform infrastructure, including secret management, access controls, and compliance.

## What You'll Learn

- Secure secret management patterns
- Implementing least-privilege access
- Encryption and data protection
- Security monitoring and alerting
- Compliance automation

## Security Features Demonstrated

### 1. Secret Management
- AWS Secrets Manager integration
- Parameter Store for configuration
- Encrypted state files
- Credential rotation policies

### 2. Access Control
- IAM roles with minimal permissions
- Resource-based policies
- Multi-factor authentication
- Service control policies

### 3. Network Security
- Security groups with least privilege
- VPC endpoints for private access
- Network ACLs and firewalls
- DDoS protection

### 4. Monitoring and Compliance
- CloudTrail for audit logging
- Config Rules for compliance
- Security Hub integration
- Automated remediation

## Prerequisites

- AWS account with security permissions
- AWS CLI configured
- Understanding of AWS security services

## Files Overview

- `main.tf` - Core security infrastructure
- `iam.tf` - Identity and access management
- `secrets.tf` - Secret management setup
- `monitoring.tf` - Security monitoring
- `compliance.tf` - Compliance automation
- `variables.tf` - Security configuration
- `outputs.tf` - Security resource outputs

## Setup Process

### 1. Configure Security Baseline
```bash
terraform init
terraform plan
terraform apply
```

### 2. Test Security Features
```bash
# Test secret retrieval
terraform output db_password_arn

# Test IAM role assumption
aws sts assume-role --role-arn $(terraform output security_role_arn)
```

### 3. Validate Compliance
```bash
# Check Config Rules
aws config describe-config-rules

# View Security Hub findings
aws securityhub get-findings
```

## Security Best Practices Implemented

### Infrastructure Security
```hcl
# Encrypted S3 bucket
resource "aws_s3_bucket" "secure" {
  bucket = var.bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Versioning for recovery
  versioning {
    enabled = true
  }

  # Public access block
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Network Security
```hcl
# Security group with specific rules
resource "aws_security_group" "secure" {
  name_prefix = "secure-sg-"
  vpc_id      = var.vpc_id

  # Minimal ingress
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Egress logging
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Access Control
```hcl
# IAM role with least privilege
resource "aws_iam_role" "secure" {
  name = "secure-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.account_id
        }
      }
    }]
  })
}

# Attach minimal policies
resource "aws_iam_role_policy_attachment" "secure" {
  role       = aws_iam_role.secure.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
```

## Monitoring and Alerting

### CloudTrail Setup
```hcl
resource "aws_cloudtrail" "secure" {
  name                          = "secure-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

### Config Rules
```hcl
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
}
```

## Compliance Automation

### Security Hub Integration
- Automated security finding aggregation
- Compliance standard integration
- Custom security checks

### Automated Remediation
- Lambda functions for auto-remediation
- Event-driven security responses
- Integration with ticketing systems

## Cost Considerations

- **Secrets Manager**: ~$0.40/secret/month
- **CloudTrail**: ~$2.50/100,000 events
- **Config**: ~$0.003/configuration item
- **Security Hub**: ~$0.10/instance/month

## Security Assessment

### Regular Audits
- Monthly security reviews
- Quarterly penetration testing
- Annual compliance audits

### Incident Response
- Defined escalation procedures
- Automated alerting
- Forensic data collection

### Continuous Improvement
- Security training programs
- Threat modeling sessions
- Security metric tracking