variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_public_subnet_cidr" {
  description = "CIDR block for AWS public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "aws_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "gcp_project" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_subnet_cidr" {
  description = "CIDR block for GCP subnet"
  type        = string
  default     = "10.1.0.0/24"
}

variable "gcp_machine_type" {
  description = "GCP compute instance machine type"
  type        = string
  default     = "e2-micro"
}