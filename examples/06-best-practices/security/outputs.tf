output "secure_bucket_name" {
  description = "Secure S3 bucket name"
  value       = aws_s3_bucket.secure_storage.bucket
}

output "security_role_arn" {
  description = "Security monitoring IAM role ARN"
  value       = aws_iam_role.security_role.arn
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = aws_kms_key.security_key.arn
}

output "secrets_manager_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.app_credentials.arn
}

output "security_group_id" {
  description = "Secure security group ID"
  value       = aws_security_group.secure_sg.id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.security_trail.arn
}

output "config_rule_arn" {
  description = "Config rule ARN"
  value       = aws_config_config_rule.s3_encryption.arn
}

output "security_summary" {
  description = "Security implementation summary"
  value = {
    encryption = {
      kms_key = aws_kms_key.security_key.arn
      s3_encryption = "AES256"
    }
    access_control = {
      iam_role = aws_iam_role.security_role.arn
      security_group = aws_security_group.secure_sg.id
    }
    monitoring = {
      cloudtrail = aws_cloudtrail.security_trail.arn
      config_rule = aws_config_config_rule.s3_encryption.arn
    }
    secrets = {
      secrets_manager = aws_secretsmanager_secret.app_credentials.arn
    }
  }
}