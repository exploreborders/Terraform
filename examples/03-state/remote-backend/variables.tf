variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "example_bucket_name" {
  description = "Name of the example S3 bucket"
  type        = string
}

variable "create_state_bucket" {
  description = "Whether to create the state bucket (set to false if using setup script)"
  type        = bool
  default     = false
}

variable "create_lock_table" {
  description = "Whether to create the lock table (set to false if using setup script)"
  type        = bool
  default     = false
}