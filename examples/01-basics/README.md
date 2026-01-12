# Basic Terraform Configuration

This example demonstrates the fundamental building blocks of Terraform:
- Provider configuration
- Resource creation
- Variables and outputs
- Basic workflow commands

## What You'll Learn

- How to configure a Terraform provider
- Creating your first resource
- Understanding Terraform's execution phases
- Using variables and outputs

## Files Overview

- `main.tf` - Main configuration with provider and resources
- `variables.tf` - Input variable definitions
- `outputs.tf` - Output value definitions
- `terraform.tfvars.example` - Example variable values

## Quick Start

1. Navigate to this directory
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in values
3. Initialize: `terraform init`
4. Plan: `terraform plan`
5. Apply: `terraform apply`
6. View outputs: `terraform output`
7. Clean up: `terraform destroy`

## When to Use This Pattern

This basic structure is the foundation for all Terraform configurations. Use it whenever you're:
- Starting a new infrastructure project
- Learning Terraform concepts
- Creating simple, standalone resources