output "vpc_id" {
  description = "Large-scale VPC ID"
  value       = aws_vpc.large_scale.id
}

output "subnet_count" {
  description = "Total number of subnets created"
  value       = length(aws_subnet.large_scale)
}

output "instance_count" {
  description = "Total number of EC2 instances created"
  value       = length(aws_instance.large_scale)
}

output "security_group_rules" {
  description = "Number of security group rules"
  value       = length(local.sg_rules)
}

output "route_table_count" {
  description = "Number of route tables created"
  value       = length(aws_route_table.large_scale)
}

output "complex_expression_result" {
  description = "Result of complex expression evaluation"
  value       = local.complex_expression
}

output "state_test_bucket" {
  description = "S3 bucket for state size testing"
  value       = aws_s3_bucket.large_scale_state_test.bucket
}

output "performance_metrics" {
  description = "Infrastructure scale metrics"
  value = {
    total_resources = (
      1 + # VPC
      1 + # IGW
      length(aws_subnet.large_scale) +
      1 + # Security group
      length(aws_route_table.large_scale) +
      length(aws_route_table_association.large_scale) +
      length(aws_instance.large_scale) +
      1 # S3 bucket
    )
    subnets_by_az = {
      for az in data.aws_availability_zones.available.names :
      az => length([
        for subnet in aws_subnet.large_scale :
        subnet if subnet.availability_zone == az
      ])
    }
    resource_distribution = {
      compute    = length(aws_instance.large_scale)
      network    = length(aws_subnet.large_scale) + length(aws_route_table.large_scale)
      security   = 1 + length(local.sg_rules) # SG + rules
      storage    = 1 # S3 bucket
    }
  }
}