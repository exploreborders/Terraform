variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "security-demo"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security resources"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "secure_bucket_name" {
  description = "Name for secure S3 bucket"
  type        = string
}