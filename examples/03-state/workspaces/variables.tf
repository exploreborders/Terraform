variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Note: Most configuration is now workspace-aware
# Variables are defined in the locals block in main.tf