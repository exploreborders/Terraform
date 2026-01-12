# Output values
output "file_path" {
  description = "Path to the created example file"
  value       = local_file.example.filename
}

output "file_content" {
  description = "Content of the example file"
  value       = local_file.example.content
  sensitive   = false
}

output "sensitive_file_path" {
  description = "Path to the sensitive file"
  value       = local_file.sensitive_example.filename
}

output "environment_info" {
  description = "Environment information"
  value = {
    name        = var.environment
    timestamp   = timestamp()
  }
}