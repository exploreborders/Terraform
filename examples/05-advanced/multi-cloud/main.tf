# Multi-Cloud Infrastructure Configuration

# Separate provider configurations
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.0"
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# GCP Provider
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# AWS Resources
# VPC for AWS resources
resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "aws-multi-cloud-vpc"
    Environment = "multi-cloud-demo"
    Cloud       = "AWS"
    ManagedBy   = "Terraform"
  }
}

# Public subnet
resource "aws_subnet" "aws_public" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.aws_public_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "aws-public-subnet"
    Environment = "multi-cloud-demo"
    Cloud       = "AWS"
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    Name        = "aws-multi-cloud-igw"
    Environment = "multi-cloud-demo"
    Cloud       = "AWS"
    ManagedBy   = "Terraform"
  }
}

# Route table
resource "aws_route_table" "aws_public" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }

  tags = {
    Name        = "aws-public-rt"
    Environment = "multi-cloud-demo"
    Cloud       = "AWS"
    ManagedBy   = "Terraform"
  }
}

# Route table association
resource "aws_route_table_association" "aws_public" {
  subnet_id      = aws_subnet.aws_public.id
  route_table_id = aws_route_table.aws_public.id
}

# Security group
resource "aws_security_group" "aws_sg" {
  name_prefix = "aws-multi-cloud-"
  vpc_id      = aws_vpc.aws_vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name        = "aws-multi-cloud-sg"
    Environment = "multi-cloud-demo"
    Cloud       = "AWS"
    ManagedBy   = "Terraform"
  }
}

# EC2 instance
resource "aws_instance" "aws_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.aws_instance_type

  vpc_security_group_ids = [aws_security_group.aws_sg.id]
  subnet_id              = aws_subnet.aws_public.id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>AWS Instance - Multi-Cloud Demo</h1><p>Running on ${var.aws_instance_type}</p>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "aws-multi-cloud-instance"
    Environment = "multi-cloud-demo"
    Cloud       = "AWS"
    ManagedBy   = "Terraform"
  }
}

# GCP Resources
# VPC network
resource "google_compute_network" "gcp_vpc" {
  name                    = "gcp-multi-cloud-vpc"
  auto_create_subnetworks = false

  routing_mode = "REGIONAL"
}

# Subnet
resource "google_compute_subnetwork" "gcp_subnet" {
  name          = "gcp-multi-cloud-subnet"
  ip_cidr_range = var.gcp_subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.gcp_vpc.id
}

# Firewall rules
resource "google_compute_firewall" "gcp_allow_ssh" {
  name    = "gcp-multi-cloud-allow-ssh"
  network = google_compute_network.gcp_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "gcp_allow_http" {
  name    = "gcp-multi-cloud-allow-http"
  network = google_compute_network.gcp_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Compute instance
resource "google_compute_instance" "gcp_instance" {
  name         = "gcp-multi-cloud-instance"
  machine_type = var.gcp_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.gcp_vpc.name
    subnetwork = google_compute_subnetwork.gcp_subnet.name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>GCP Instance - Multi-Cloud Demo</h1><p>Running on ${var.gcp_machine_type}</p>" > /var/www/html/index.html
  EOF

  tags = ["multi-cloud-demo"]

  labels = {
    environment = "multi-cloud-demo"
    cloud       = "gcp"
    managed_by  = "terraform"
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