# Configure the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}

# AWS provider configuration
provider "aws" {
  region = var.aws_region

  # Credentials should be configured via AWS CLI or environment variables
  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for the EC2 instance
resource "aws_security_group" "instance_sg" {
  name_prefix = "terraform-example-"
  description = "Security group for Terraform example EC2 instance"

  # Ingress rules
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule (allow all outbound)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-example-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Lifecycle to create replacement before destroying
  lifecycle {
    create_before_destroy = true
  }
}

# EC2 instance
resource "aws_instance" "example" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  # User data script to install web server
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform! Instance: ${var.instance_name}</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Depends on security group
  depends_on = [aws_security_group.instance_sg]

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      # Ignore changes to user_data to prevent replacement on script updates
      user_data,
    ]
  }
}