# Terraform Workspaces

This example demonstrates using Terraform workspaces to manage multiple environments
(dev, staging, prod) with the same infrastructure code but isolated state.

## What You'll Learn

- Creating and managing workspaces
- Environment-specific configurations
- State isolation between workspaces
- Variable management across environments
- Best practices for multi-environment deployments

## Prerequisites

- AWS CLI configured
- Remote backend configured (recommended)

## Files Overview

- `main.tf` - Infrastructure configuration with workspace-aware variables
- `variables.tf` - Variable definitions with workspace logic
- `outputs.tf` - Environment-specific outputs
- `terraform.tfvars.example` - Base configuration example
- `workspace-setup.sh` - Script to create and configure workspaces

## Workspace Concepts

### What are Workspaces?
Workspaces allow you to manage multiple instances of the same infrastructure configuration.
Each workspace has its own state file and can have different variable values.

### Common Use Cases
- **Multiple Environments**: dev, staging, production
- **Feature Branches**: Testing changes in isolation
- **Regional Deployments**: Same config, different regions
- **Customer-specific**: Multi-tenant applications

## Getting Started

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Create Workspaces

Use the setup script or create manually:

```bash
chmod +x workspace-setup.sh
./workspace-setup.sh
```

Or manually:
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

### 3. Switch Between Workspaces

```bash
terraform workspace select dev
terraform workspace list  # Shows current workspace with *
```

### 4. Deploy to Different Environments

```bash
# Deploy to dev
terraform workspace select dev
terraform apply

# Deploy to staging
terraform workspace select staging
terraform apply

# Deploy to prod
terraform workspace select prod
terraform apply
```

## Workspace Variables

This example shows how variables can be customized per workspace:

- **dev**: Smaller instances, basic configuration
- **staging**: Medium instances, more resources
- **prod**: Larger instances, high availability

## State Isolation

Each workspace maintains its own state:
- `terraform.tfstate.d/dev/terraform.tfstate`
- `terraform.tfstate.d/staging/terraform.tfstate`
- `terraform.tfstate.d/prod/terraform.tfstate`

## Best Practices

- **Naming**: Use consistent workspace naming (dev, staging, prod)
- **Variables**: Use workspace-aware variable files
- **State**: Combine workspaces with remote backends
- **Testing**: Test workspace switches thoroughly
- **Documentation**: Document workspace purposes and differences

## Remote Backend with Workspaces

When using remote backends, workspace state is stored with workspace-specific keys:
```
bucket/key/dev/terraform.tfstate
bucket/key/staging/terraform.tfstate
bucket/key/prod/terraform.tfstate
```

## Common Commands

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new <name>

# Switch workspace
terraform workspace select <name>

# Show current workspace
terraform workspace show

# Delete workspace (must be empty first)
terraform workspace delete <name>
```