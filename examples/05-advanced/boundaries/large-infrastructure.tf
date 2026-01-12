# Large-Scale Infrastructure Example

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

# Data sources for large-scale operations
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Generate large number of subnets for testing limits
locals {
  # Create 50 subnets across available AZs
  subnet_count = 50
  az_count     = length(data.aws_availability_zones.available.names)

  # Distribute subnets across AZs
  subnets_per_az = ceil(local.subnet_count / local.az_count)

  # Generate subnet configurations
  subnet_configs = flatten([
    for az_index in range(local.az_count) : [
      for subnet_index in range(local.subnets_per_az) : {
        az_index     = az_index
        subnet_index = subnet_index
        cidr_block   = cidrsubnet(var.vpc_cidr, 8, (az_index * local.subnets_per_az) + subnet_index)
        az_name      = data.aws_availability_zones.available.names[az_index]
      } if (az_index * local.subnets_per_az) + subnet_index < local.subnet_count
    ]
  ])

  # Generate security group rules (100 rules for complexity)
  sg_rule_count = 100
  sg_rules = [
    for i in range(local.sg_rule_count) : {
      from_port   = 80 + i
      to_port     = 80 + i
      protocol    = "tcp"
      cidr_blocks = [format("10.%d.0.0/16", i % 256)]
      description = "Rule ${i}"
    }
  ]

  # Complex expressions for testing limits
  complex_expression = {
    nested_maps = {
      level1 = {
        level2 = {
          level3 = {
            computed_value = sha256(join("-", [
              for i in range(100) : format("item-%d", i)
            ]))
            array_values = [
              for i in range(50) : {
                index = i
                value = base64encode(format("Complex data item %d", i))
                hash  = md5(format("hash-%d", i))
              }
            ]
          }
        }
      }
    }
    computed_cidrs = [
      for i in range(20) : cidrsubnet("10.0.0.0/8", 16, i)
    ]
    conditional_values = var.enable_complex_features ? {
      feature_a = "enabled"
      feature_b = local.complex_expression.nested_maps.level1.level2.level3.computed_value
    } : {}
  }
}

# VPC for large-scale infrastructure
resource "aws_vpc" "large_scale" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name        = "large-scale-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "Boundary Testing"
    },
    local.complex_expression.conditional_values
  )
}

# Internet Gateway
resource "aws_internet_gateway" "large_scale" {
  vpc_id = aws_vpc.large_scale.id

  tags = {
    Name        = "large-scale-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Large number of subnets (testing resource count limits)
resource "aws_subnet" "large_scale" {
  for_each = {
    for config in local.subnet_configs : "${config.az_name}-${config.subnet_index}" => config
  }

  vpc_id            = aws_vpc.large_scale.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az_name

  tags = {
    Name        = "large-scale-subnet-${each.key}"
    Environment = var.environment
    AZ          = each.value.az_name
    ManagedBy   = "Terraform"
    Index       = each.value.subnet_index
  }
}

# Security group with many rules (testing complexity)
resource "aws_security_group" "large_scale" {
  name_prefix = "large-scale-sg-"
  vpc_id      = aws_vpc.large_scale.id

  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = local.sg_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "large-scale-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
    RuleCount   = local.sg_rule_count
  }
}

# Route table for each subnet (testing dependency complexity)
resource "aws_route_table" "large_scale" {
  for_each = aws_subnet.large_scale

  vpc_id = aws_vpc.large_scale.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.large_scale.id
  }

  tags = {
    Name        = "large-scale-rt-${each.key}"
    Environment = var.environment
    Subnet      = each.key
    ManagedBy   = "Terraform"
  }
}

# Route table associations (creating dependency chains)
resource "aws_route_table_association" "large_scale" {
  for_each = aws_subnet.large_scale

  subnet_id      = each.value.id
  route_table_id = aws_route_table.large_scale[each.key].id
}

# EC2 instances (one per subnet, testing resource scaling)
resource "aws_instance" "large_scale" {
  for_each = aws_subnet.large_scale

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.large_scale.id]
  subnet_id              = each.value.id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Large Scale Instance</h1><p>Subnet: ${each.key}</p><p>AZ: ${each.value.availability_zone}</p>" > /var/www/html/index.html
              EOF

  tags = merge(
    {
      Name        = "large-scale-instance-${each.key}"
      Environment = var.environment
      Subnet      = each.key
      AZ          = each.value.availability_zone
      ManagedBy   = "Terraform"
    },
    local.complex_expression.conditional_values
  )
}

# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# S3 bucket for testing state size limits
resource "aws_s3_bucket" "large_scale_state_test" {
  bucket = var.state_test_bucket_name

  tags = {
    Name        = var.state_test_bucket_name
    Environment = var.environment
    Purpose     = "State Size Testing"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for state testing
resource "aws_s3_bucket_versioning" "large_scale_state_test" {
  bucket = aws_s3_bucket.large_scale_state_test.id
  versioning_configuration {
    status = "Enabled"
  }
}