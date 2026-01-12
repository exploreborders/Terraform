# AWS outputs
output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = aws_vpc.aws_vpc.id
}

output "aws_instance_public_ip" {
  description = "AWS EC2 instance public IP"
  value       = aws_instance.aws_instance.public_ip
}

output "aws_instance_id" {
  description = "AWS EC2 instance ID"
  value       = aws_instance.aws_instance.id
}

# GCP outputs
output "gcp_vpc_id" {
  description = "GCP VPC network ID"
  value       = google_compute_network.gcp_vpc.id
}

output "gcp_instance_external_ip" {
  description = "GCP compute instance external IP"
  value       = google_compute_instance.gcp_instance.network_interface[0].access_config[0].nat_ip
}

output "gcp_instance_internal_ip" {
  description = "GCP compute instance internal IP"
  value       = google_compute_instance.gcp_instance.network_interface[0].network_ip
}

# Multi-cloud summary
output "multi_cloud_deployment" {
  description = "Summary of multi-cloud deployment"
  value = {
    aws = {
      region      = var.aws_region
      vpc_id      = aws_vpc.aws_vpc.id
      instance_ip = aws_instance.aws_instance.public_ip
      cloud       = "AWS"
    }
    gcp = {
      region      = var.gcp_region
      vpc_id      = google_compute_network.gcp_vpc.id
      instance_ip = google_compute_instance.gcp_instance.network_interface[0].access_config[0].nat_ip
      cloud       = "GCP"
    }
  }
}