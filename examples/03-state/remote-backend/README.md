# Remote Backend Configuration

This example demonstrates setting up a remote backend using AWS S3 with DynamoDB for state locking.
It shows how to migrate from local state to remote state and manage state securely.

## What You'll Learn

- Configuring S3 backend for remote state storage
- Setting up DynamoDB for state locking
- Migrating state from local to remote
- Backend configuration best practices
- State file security and access control

## Prerequisites

- AWS CLI configured with administrative permissions
- S3 bucket creation permissions
- DynamoDB table creation permissions

## Files Overview

- `main.tf` - Simple infrastructure to demonstrate state
- `backend.tf` - Remote backend configuration
- `variables.tf` - Configuration variables
- `outputs.tf` - Resource outputs
- `terraform.tfvars.example` - Example variables
- `setup-backend.sh` - Script to create S3 bucket and DynamoDB table

## Setup Process

### 1. Create Backend Resources

First, create the S3 bucket and DynamoDB table:

```bash
chmod +x setup-backend.sh
./setup-backend.sh
```

This script creates:
- S3 bucket for state storage
- DynamoDB table for state locking
- Proper IAM policies and versioning

### 2. Configure Backend

The `backend.tf` file contains the remote backend configuration. Update the bucket name and region to match your setup.

### 3. Initialize and Migrate

```bash
terraform init
# This will prompt to migrate state to remote backend
terraform plan
terraform apply
```

## Backend Configuration Explained

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

## State Locking Demonstration

Try running `terraform apply` from two terminals simultaneously. The second one will wait for the first to complete due to state locking.

## Security Considerations

- **Encryption**: State files are encrypted at rest in S3
- **Access Control**: Use IAM policies to restrict access
- **Versioning**: S3 versioning protects against accidental deletions
- **Backup**: Regular state file backups

## When to Use Remote Backend

- **Team Collaboration**: Multiple developers working on same infrastructure
- **CI/CD Pipelines**: Automated deployments need consistent state
- **Production Environments**: Critical infrastructure requires reliable state management
- **Disaster Recovery**: Remote state survives local machine failures