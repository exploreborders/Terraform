# Configure backend (can be local or remote)
terraform {
  # Uncomment for remote backend
  # backend "s3" {
  #   bucket         = "your-state-bucket"
  #   key            = "examples/state/workspaces/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }

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

# Get current workspace name
locals {
  workspace = terraform.workspace

  # Workspace-specific configurations
  config = {
    dev = {
      instance_type = "t2.micro"
      instance_count = 1
      environment = "dev"
    }
    staging = {
      instance_type = "t2.small"
      instance_count = 2
      environment = "staging"
    }
    prod = {
      instance_type = "t2.medium"
      instance_count = 3
      environment = "prod"
    }
  }

  # Get current workspace config
  current_config = lookup(local.config, local.workspace, local.config["dev"])
}

# VPC lookup (assuming VPC exists from previous examples)
data "aws_vpc" "selected" {
  tags = {
    Environment = local.current_config.environment
  }
}

# Security group
resource "aws_security_group" "workspace_sg" {
  name_prefix = "${local.workspace}-workspace-sg-"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.workspace}-workspace-sg"
    Environment = local.current_config.environment
    Workspace   = local.workspace
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 instances (count based on workspace)
resource "aws_instance" "workspace_instances" {
  count         = local.current_config.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.current_config.instance_type

  vpc_security_group_ids = [aws_security_group.workspace_sg.id]
  subnet_id              = data.aws_subnets.public.ids[0]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Environment: ${local.workspace}</h1><p>Instance: ${count.index + 1}</p>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "${local.workspace}-instance-${count.index + 1}"
    Environment = local.current_config.environment
    Workspace   = local.workspace
    ManagedBy   = "Terraform"
  }
}

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}