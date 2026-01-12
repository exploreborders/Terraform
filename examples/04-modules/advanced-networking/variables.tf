variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "hub_vpc_cidr" {
  description = "CIDR block for hub VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_public_subnets" {
  description = "Public subnets for hub VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "hub_private_subnets" {
  description = "Private subnets for hub VPC"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}