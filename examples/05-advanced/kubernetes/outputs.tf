# VPC outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# EKS cluster outputs
output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_region" {
  description = "AWS region of the cluster"
  value       = var.aws_region
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL for IRSA"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Node group outputs
output "node_group_name" {
  description = "EKS node group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "node_instance_types" {
  description = "Node group instance types"
  value       = aws_eks_node_group.main.instance_types
}

# kubeconfig command
output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}"
}

# Cluster summary
output "cluster_summary" {
  description = "Complete cluster configuration summary"
  value = {
    name             = aws_eks_cluster.main.name
    region           = var.aws_region
    version          = aws_eks_cluster.main.version
    endpoint         = aws_eks_cluster.main.endpoint
    vpc_id           = aws_vpc.eks.id
    node_group       = aws_eks_node_group.main.node_group_name
    node_count       = aws_eks_node_group.main.scaling_config[0].desired_size
    instance_types   = aws_eks_node_group.main.instance_types
    oidc_issuer      = aws_eks_cluster.main.identity[0].oidc[0].issuer
  }
}