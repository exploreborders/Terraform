# RDS Database Instance

This example demonstrates provisioning an Amazon RDS database instance with security groups and parameter groups.
It covers database resource management and best practices.

## What You'll Learn

- RDS instance provisioning
- Database security groups
- Parameter groups and option groups
- Multi-AZ deployment
- Backup and maintenance windows
- Database subnet groups

## Prerequisites

- AWS CLI configured with credentials
- VPC created (can use the vpc-network example)
- Permissions for RDS operations

## Files Overview

- `main.tf` - RDS instance and related resources
- `variables.tf` - Database configuration variables
- `outputs.tf` - Database connection information
- `terraform.tfvars.example` - Example configurations

## When to Use This Pattern

- Provisioning managed databases
- Setting up databases for applications
- Implementing database security best practices
- When you need automated backups and maintenance

## Important Notes

- RDS instances incur costs even when not in use
- Database credentials are stored in state - use secret management in production
- Consider using Aurora for better performance/cost ratio