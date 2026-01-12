variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "boundaries-test"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/8"
}

variable "enable_complex_features" {
  description = "Enable complex expressions and features"
  type        = bool
  default     = false
}

variable "state_test_bucket_name" {
  description = "Name for S3 bucket to test state limits"
  type        = string
  default     = "terraform-boundaries-state-test-20241212"
}