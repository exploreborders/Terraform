# VPC Network Configuration

This example demonstrates creating a basic AWS VPC with subnets, internet gateway, and route tables.
It shows how to manage network infrastructure as code.

## What You'll Learn

- VPC resource creation and configuration
- Subnet management (public/private)
- Internet Gateway and NAT Gateway setup
- Route table configuration
- Network ACLs and security groups
- Resource dependencies and ordering

## Prerequisites

- AWS CLI configured with credentials
- Permissions for VPC, subnet, and networking operations

## Files Overview

- `main.tf` - VPC, subnets, gateways, and route tables
- `variables.tf` - Network configuration variables
- `outputs.tf` - Network resource outputs
- `terraform.tfvars.example` - Example configurations

## Architecture

This creates:
- 1 VPC with CIDR 10.0.0.0/16
- 2 public subnets across 2 availability zones
- 2 private subnets across 2 availability zones
- 1 Internet Gateway
- 1 NAT Gateway (for private subnet outbound access)
- Route tables for public and private subnets

## When to Use This Pattern

- Setting up network foundations for applications
- Creating isolated environments
- Implementing multi-tier architectures
- When you need custom networking beyond default VPC