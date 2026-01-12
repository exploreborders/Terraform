# Advanced Networking Configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Hub network configuration
module "hub_network" {
  source = "../../../modules/network"

  name                = "hub-network"
  vpc_cidr           = var.hub_vpc_cidr
  public_subnet_cidrs = var.hub_public_subnets
  private_subnet_cidrs = var.hub_private_subnets
  create_nat_gateway = true
  environment        = "hub"

  tags = {
    Purpose = "Shared Services Hub"
    Type    = "Hub"
  }
}

# Transit Gateway for hub-and-spoke connectivity
resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway for hub-and-spoke networking"

  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name        = "terraform-learning-tgw"
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}

# Transit Gateway VPC attachment for hub
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.hub_network.vpc_id
  subnet_ids         = module.hub_network.private_subnet_ids

  tags = {
    Name        = "hub-attachment"
    Environment = "hub"
    ManagedBy   = "Terraform"
  }
}

# Spoke networks with different configurations
locals {
  spoke_configs = {
    app1 = {
      name                = "app1-spoke"
      vpc_cidr           = "10.10.0.0/16"
      public_subnets     = ["10.10.1.0/24", "10.10.2.0/24"]
      private_subnets    = ["10.10.10.0/24", "10.10.11.0/24"]
      enable_nat         = true
      environment        = "app1"
    }
    app2 = {
      name                = "app2-spoke"
      vpc_cidr           = "10.11.0.0/16"
      public_subnets     = ["10.11.1.0/24"]
      private_subnets    = ["10.11.10.0/24"]
      enable_nat         = false  # Cost optimization
      environment        = "app2"
    }
    security = {
      name                = "security-spoke"
      vpc_cidr           = "10.12.0.0/16"
      public_subnets     = []
      private_subnets    = ["10.12.10.0/24", "10.12.11.0/24", "10.12.12.0/24"]
      enable_nat         = true
      environment        = "security"
    }
  }
}

# Create spoke networks
module "spoke_networks" {
  for_each = local.spoke_configs

  source = "../../../modules/network"

  name                = each.value.name
  vpc_cidr           = each.value.vpc_cidr
  public_subnet_cidrs = each.value.public_subnets
  private_subnet_cidrs = each.value.private_subnets
  create_nat_gateway = each.value.enable_nat
  environment        = each.value.environment

  tags = {
    Purpose = "Application Spoke"
    Type    = "Spoke"
    App     = each.key
  }
}

# Transit Gateway attachments for spokes
resource "aws_ec2_transit_gateway_vpc_attachment" "spokes" {
  for_each = module.spoke_networks

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.private_subnet_ids

  tags = {
    Name        = "${each.key}-attachment"
    Environment = each.value.environment
    ManagedBy   = "Terraform"
  }
}

# Route tables for Transit Gateway routes
resource "aws_route" "spoke_to_hub" {
  for_each = module.spoke_networks

  route_table_id         = each.value.private_route_table_id != null ? each.value.private_route_table_id : each.value.public_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.spokes]
}

# Hub route to spokes (propagated automatically with default settings)

# Security groups for cross-VPC communication
resource "aws_security_group" "cross_vpc" {
  name_prefix = "cross-vpc-"
  vpc_id      = module.hub_network.vpc_id

  ingress {
    description = "Allow all traffic from spoke VPCs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for spoke in module.spoke_networks : spoke.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cross-vpc-sg"
    Environment = "hub"
    ManagedBy   = "Terraform"
  }
}