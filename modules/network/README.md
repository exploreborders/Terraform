# Terraform AWS Network Module

This module creates a complete AWS network infrastructure including VPC, subnets, internet gateway, NAT gateway, and route tables. It's designed to be highly reusable and configurable for different environments and use cases.

## Features

- **VPC Creation**: Configurable CIDR blocks and DNS settings
- **Subnet Management**: Public and private subnets across multiple AZs
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound access (optional)
- **Route Tables**: Separate routing for public/private subnets
- **Security**: Input validation and resource tagging
- **Flexibility**: Highly configurable for different network architectures

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  # Required
  name = "my-network"
  vpc_cidr = "10.0.0.0/16"

  # Optional
  environment = "dev"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  create_nat_gateway = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for all resources | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | n/a | yes |
| environment | Environment name for tagging | `string` | `"dev"` | no |
| public_subnet_cidrs | List of CIDR blocks for public subnets | `list(string)` | `[]` | no |
| private_subnet_cidrs | List of CIDR blocks for private subnets | `list(string)` | `[]` | no |
| create_nat_gateway | Whether to create NAT Gateway for private subnets | `bool` | `true` | no |
| enable_dns_hostnames | Whether to enable DNS hostnames in VPC | `bool` | `true` | no |
| enable_dns_support | Whether to enable DNS support in VPC | `bool` | `true` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the created VPC |
| vpc_cidr | CIDR block of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| internet_gateway_id | ID of the Internet Gateway |
| nat_gateway_id | ID of the NAT Gateway (if created) |
| public_route_table_id | ID of the public route table |
| private_route_table_id | ID of the private route table |

## Examples

### Basic Network
```hcl
module "network" {
  source = "./modules/network"

  name     = "basic-network"
  vpc_cidr = "10.0.0.0/16"
}
```

### Multi-AZ Production Network
```hcl
module "network" {
  source = "./modules/network"

  name = "prod-network"
  vpc_cidr = "10.0.0.0/16"
  environment = "prod"

  public_subnet_cidrs = [
    "10.0.1.0/24",  # us-east-1a
    "10.0.2.0/24",  # us-east-1b
    "10.0.3.0/24"   # us-east-1c
  ]

  private_subnet_cidrs = [
    "10.0.10.0/24", # us-east-1a
    "10.0.11.0/24", # us-east-1b
    "10.0.12.0/24"  # us-east-1c
  ]

  create_nat_gateway = true
}
```

## Validation Rules

- VPC CIDR must be a valid IPv4 CIDR block
- Subnet CIDRs must be within VPC CIDR range
- Number of public/private subnets must match (for AZ distribution)

## Resource Tagging

All resources are tagged with:
- `Name`: Resource-specific name with prefix
- `Environment`: Environment name
- `ManagedBy`: "Terraform"
- `Module`: "network"
- Additional custom tags from `tags` input

## Dependencies

This module creates resources in the following order:
1. VPC
2. Internet Gateway
3. Public Subnets
4. Private Subnets
5. NAT Gateway (if enabled)
6. Route Tables and Associations

## Testing

To test this module:
```bash
cd examples/04-modules/multi-environment
terraform init
terraform plan
terraform apply
```