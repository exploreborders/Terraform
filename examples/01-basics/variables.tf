# Input variables
variable "name" {
  description = "A name to include in the greeting"
  type        = string
  default     = "World"
}

variable "secret_value" {
  description = "A sensitive value for demonstration"
  type        = string
  sensitive   = true
  default     = "default_secret"
}

# Variable with validation
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}