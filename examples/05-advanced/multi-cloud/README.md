# Multi-Cloud Infrastructure Deployment

This example demonstrates deploying infrastructure across multiple cloud providers (AWS and GCP) using Terraform. It showcases multi-provider configurations, cross-cloud networking considerations, and unified state management.

## What You'll Learn

- Configuring multiple providers in a single configuration
- Cross-cloud resource dependencies
- Multi-provider state management
- Provider-specific resource configurations
- Cost optimization across clouds

## Architecture

### AWS Resources
- VPC with public/private subnets
- EC2 instance in public subnet
- Security groups for access control

### GCP Resources
- VPC network with subnets
- Compute Engine instance
- Firewall rules for access control

### Cross-Cloud Considerations
- Separate state management per provider (recommended)
- Networking isolation between clouds
- Cost monitoring and optimization

## Prerequisites

### AWS
- AWS CLI configured with credentials
- Permissions for EC2, VPC operations

### GCP
- GCP project created
- Service account with appropriate permissions
- gcloud CLI installed and configured

## Files Overview

- `main.tf` - Multi-provider configuration and resources
- `providers.tf` - Provider configurations with aliases
- `variables.tf` - Configuration variables for both clouds
- `outputs.tf` - Resource outputs from both providers
- `terraform.tfvars.example` - Example configurations

## Setup Process

### 1. Configure AWS
```bash
aws configure
# Enter your AWS credentials
```

### 2. Configure GCP
```bash
# Create service account and download key
gcloud auth activate-service-account --key-file=gcp-key.json
gcloud config set project YOUR_PROJECT_ID
```

### 3. Initialize and Deploy
```bash
terraform init
terraform plan
terraform apply
```

## Provider Configuration

```hcl
# AWS Provider
provider "aws" {
  region = var.aws_region
}

# GCP Provider
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
```

## State Management

This example uses separate state files for each provider to avoid complexity. For production, consider:

- Separate Terraform configurations per provider
- Remote state backends per provider
- Cross-cloud resource references (limited)

## Cost Optimization

### AWS
- t2.micro instances (free tier eligible)
- Minimal networking resources

### GCP
- e2-micro instances (free tier eligible)
- f1-micro alternative for always-free

## Security Considerations

- Use separate credentials for each provider
- Implement least-privilege access
- Encrypt sensitive data in state files
- Regular credential rotation

## Cleanup

```bash
terraform destroy
```

**Note**: Ensure both providers are properly configured before destroying to avoid orphaned resources.