output "current_workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "instance_count" {
  description = "Number of instances in current workspace"
  value       = local.current_config.instance_count
}

output "instance_type" {
  description = "Instance type for current workspace"
  value       = local.current_config.instance_type
}

output "environment" {
  description = "Environment for current workspace"
  value       = local.current_config.environment
}

output "instance_ids" {
  description = "IDs of created instances"
  value       = aws_instance.workspace_instances[*].id
}

output "instance_public_ips" {
  description = "Public IPs of created instances"
  value       = aws_instance.workspace_instances[*].public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.workspace_sg.id
}

output "vpc_id" {
  description = "VPC ID being used"
  value       = data.aws_vpc.selected.id
}