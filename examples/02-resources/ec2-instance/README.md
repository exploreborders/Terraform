# AWS EC2 Instance Provisioning

This example demonstrates provisioning an Amazon EC2 instance with a security group.
It showcases core resource management concepts including dependencies, lifecycle, and data sources.

## What You'll Learn

- AWS provider configuration and authentication
- EC2 instance resource creation
- Security group configuration
- Resource dependencies and references
- Data sources for dynamic information
- Tagging strategies

## Prerequisites

- AWS CLI configured with credentials (`aws configure`)
- Appropriate AWS permissions for EC2 operations
- Default VPC in your AWS account

## Files Overview

- `main.tf` - EC2 instance and security group resources
- `variables.tf` - Input variables for customization
- `outputs.tf` - Output values for the created resources
- `data.tf` - Data sources for AMI and availability zones
- `terraform.tfvars.example` - Example variable values

## Quick Start

1. Configure AWS credentials: `aws configure`
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Initialize: `terraform init`
4. Plan: `terraform plan`
5. Apply: `terraform apply`
6. View outputs: `terraform output`
7. Clean up: `terraform destroy`

## When to Use This Pattern

- Provisioning individual EC2 instances for development/testing
- Creating infrastructure with specific instance types and configurations
- Managing security groups for network access control
- When you need fine-grained control over EC2 resources

## Cost Considerations

This example creates billable AWS resources. The t2.micro instance type is eligible for the free tier if you qualify.

## Security Notes

- Never commit AWS credentials to version control
- Use IAM roles instead of access keys when possible
- Restrict security group rules to necessary ports only