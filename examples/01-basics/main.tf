# Configure the Terraform provider
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.0"
}

# Provider configuration
provider "local" {}

# Create a local file resource
resource "local_file" "example" {
  content  = "Hello, ${var.name}! This is your first Terraform resource."
  filename = "${path.module}/example.txt"
}

# Create a sensitive file (demonstrates sensitive handling)
resource "local_file" "sensitive_example" {
  content  = "This contains sensitive data: ${var.secret_value}"
  filename = "${path.module}/sensitive.txt"
}

# Resource demonstrating lifecycle
resource "local_file" "lifecycle_example" {
  content  = "Created at: ${timestamp()}"
  filename = "${path.module}/lifecycle.txt"

  lifecycle {
    create_before_destroy = true
  }
}