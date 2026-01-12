# Network Module Configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name        = "${var.name}-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.name}-igw"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "${var.name}-public-subnet-${count.index + 1}"
      Environment = var.environment
      Type        = "Public"
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name        = "${var.name}-private-subnet-${count.index + 1}"
      Environment = var.environment
      Type        = "Private"
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )
}

# EIP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  vpc   = true

  tags = merge(
    {
      Name        = "${var.name}-nat-eip"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      Name        = "${var.name}-nat-gateway"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name        = "${var.name}-public-rt"
      Environment = var.environment
      Type        = "Public"
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )
}

# Private Route Table
resource "aws_route_table" "private" {
  count  = var.create_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(
    {
      Name        = "${var.name}-private-rt"
      Environment = var.environment
      Type        = "Private"
      ManagedBy   = "Terraform"
      Module      = "network"
    },
    var.tags
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.create_nat_gateway ? aws_route_table.private[0].id : aws_route_table.public.id
}