# Multi-Environment Network Configuration

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

# Environment-specific network configurations
locals {
  environments = {
    dev = {
      name                = "dev-network"
      vpc_cidr           = "10.0.0.0/16"
      public_subnet_cidrs = ["10.0.1.0/24"]
      private_subnet_cidrs = ["10.0.10.0/24"]
      create_nat_gateway = true
      environment        = "dev"
    }
    staging = {
      name                = "staging-network"
      vpc_cidr           = "10.1.0.0/16"
      public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
      private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
      create_nat_gateway = true
      environment        = "staging"
    }
    prod = {
      name                = "prod-network"
      vpc_cidr           = "10.2.0.0/16"
      public_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
      private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
      create_nat_gateway = true
      environment        = "prod"
    }
  }
}

# Deploy networks for each environment
module "networks" {
  for_each = local.environments

  source = "../../../modules/network"

  name                = each.value.name
  vpc_cidr           = each.value.vpc_cidr
  public_subnet_cidrs = each.value.public_subnet_cidrs
  private_subnet_cidrs = each.value.private_subnet_cidrs
  create_nat_gateway = each.value.create_nat_gateway
  environment        = each.value.environment

  tags = {
    Project     = "terraform-learning"
    Owner       = "terraform-student"
    CostCenter  = each.value.environment
  }
}