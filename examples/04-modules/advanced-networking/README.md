# Advanced Networking with Modules

This example demonstrates advanced module usage including module composition,
conditional logic, and complex network architectures.

## What You'll Learn

- Module composition (modules calling other modules)
- Conditional module instantiation
- Complex network topologies
- Module dependency management
- Advanced Terraform patterns

## Architecture

Creates a hub-and-spoke network architecture:

### Hub Network
- Central VPC for shared services
- Transit Gateway for cross-VPC connectivity
- VPN Gateway for external connections

### Spoke Networks
- Application VPCs connected via Transit Gateway
- Isolated environments with different security requirements
- Conditional NAT Gateway based on environment needs

### Shared Services
- Centralized logging and monitoring VPC
- Security VPC with firewall appliances

## Features Demonstrated

- **Module Loops**: Using `for_each` with modules
- **Conditional Modules**: Modules created based on conditions
- **Module Outputs**: Passing outputs between modules
- **Complex Dependencies**: Managing inter-module dependencies
- **Resource Sharing**: Transit Gateway for VPC connectivity

## Files Overview

- `main.tf` - Complex module orchestration
- `modules/` - Sub-modules for different network types
- `variables.tf` - Configuration for complex setup
- `outputs.tf` - Comprehensive outputs

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Network Components

### Hub Components
- Transit Gateway
- VPN Gateway
- Route tables for spoke connectivity

### Spoke Components
- Application VPCs with different configurations
- Conditional NAT Gateway creation
- Transit Gateway attachments

### Security Components
- Security VPC with network firewalls
- Centralized logging VPC
- Route filtering and security groups

## Advanced Patterns

### Module Composition
```hcl
module "hub" {
  source = "./modules/hub"
  # ... configuration
}

module "spokes" {
  for_each = var.spoke_configs
  source   = "./modules/spoke"

  hub_id = module.hub.transit_gateway_id
  # ... spoke-specific config
}
```

### Conditional Logic
```hcl
module "nat_gateway" {
  count  = var.enable_nat_gateway ? 1 : 0
  source = "./modules/nat"
  # ... config
}
```

## Cost Considerations

- **Transit Gateway**: ~$36.50/month + $0.02/GB data transfer
- **VPN Gateway**: ~$36/month + data transfer costs
- **NAT Gateway**: ~$32/month per VPC (conditional)
- **VPC Endpoints**: Minimal costs

## Cleanup

```bash
terraform destroy
```

**Note**: Transit Gateway attachments must be removed before destroying VPCs.