# Multi-Environment Network Deployment

This example demonstrates using the network module across multiple environments
(dev, staging, prod) with different configurations for each environment.

## What You'll Learn

- Using modules with different configurations
- Environment-specific network architectures
- Module reusability across environments
- Managing complexity with modules

## Architecture

- **Dev**: Basic network with NAT gateway
- **Staging**: Multi-AZ network with NAT gateway
- **Prod**: High-availability multi-AZ network with NAT gateway

## Files Overview

- `main.tf` - Module calls for each environment
- `variables.tf` - Environment configurations
- `outputs.tf` - Combined outputs from all environments
- `terraform.tfvars.example` - Example configurations

## Usage

### Deploy All Environments

```bash
terraform init
terraform plan
terraform apply
```

### Deploy Specific Environment

Use Terraform workspaces:

```bash
terraform workspace select dev
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

## Environment Configurations

### Development
- Single AZ setup
- Basic networking for development work
- Cost-effective for experimentation

### Staging
- Multi-AZ setup
- Mirrors production architecture
- Used for testing and validation

### Production
- Full high-availability setup
- Multiple AZs for resilience
- Production-grade networking

## Cost Considerations

- **NAT Gateway**: ~$32/month per environment
- **EIPs**: Minimal cost
- **VPC/Route Tables**: No additional cost

## Cleanup

To destroy all environments:

```bash
terraform destroy
```

Or destroy specific environment:

```bash
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"
```