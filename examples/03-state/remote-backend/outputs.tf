output "state_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state"
  value       = var.state_bucket_name
}

output "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = var.lock_table_name
}

output "example_bucket_name" {
  description = "Name of the created example S3 bucket"
  value       = aws_s3_bucket.example.bucket
}

output "example_bucket_arn" {
  description = "ARN of the example S3 bucket"
  value       = aws_s3_bucket.example.arn
}

output "example_bucket_domain_name" {
  description = "Domain name of the example S3 bucket"
  value       = aws_s3_bucket.example.bucket_domain_name
}