# Kubernetes Cluster with EKS

This example demonstrates provisioning a complete Amazon EKS (Elastic Kubernetes Service) cluster with managed node groups, VPC integration, and necessary IAM roles. It showcases Terraform's integration with Kubernetes infrastructure.

## What You'll Learn

- EKS cluster provisioning and configuration
- Managed node groups for worker nodes
- VPC integration with Kubernetes networking
- IAM roles for service accounts (IRSA)
- Cluster add-ons and security groups
- kubectl integration and kubeconfig management

## Architecture

### EKS Cluster
- Managed Kubernetes control plane
- Three availability zones for high availability
- Managed node groups with auto-scaling

### Networking
- Dedicated VPC with private/public subnets
- NAT gateways for outbound traffic
- Security groups for cluster communication

### Security
- IAM roles for cluster access
- Service account roles for pod permissions
- Network policies for pod security

## Prerequisites

- AWS CLI configured with EKS permissions
- kubectl installed locally
- aws-iam-authenticator configured
- Permissions for EKS, EC2, IAM, VPC operations

## Files Overview

- `main.tf` - EKS cluster, node groups, and networking
- `vpc.tf` - VPC and subnet configuration
- `security.tf` - Security groups and IAM roles
- `variables.tf` - Configuration variables
- `outputs.tf` - Cluster access information
- `terraform.tfvars.example` - Example configurations

## Setup Process

### 1. Configure AWS CLI
```bash
aws configure
# Ensure you have EKS permissions
```

### 2. Initialize Terraform
```bash
terraform init
terraform plan
terraform apply
```

### 3. Configure kubectl
```bash
# Get kubeconfig
aws eks update-kubeconfig --name $(terraform output cluster_name) --region $(terraform output cluster_region)

# Test connection
kubectl get nodes
kubectl get pods -A
```

## Cluster Configuration

The EKS cluster includes:
- **Control Plane**: Managed by AWS
- **Worker Nodes**: Managed node groups with auto-scaling
- **Networking**: Calico or AWS VPC CNI
- **Add-ons**: CoreDNS, kube-proxy, VPC CNI

## Node Group Configuration

```hcl
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
  # ... additional config
}
```

## Security Considerations

### IAM Roles
- Cluster admin role for management
- Node instance role for EC2 permissions
- Service account roles for pod access

### Network Security
- Private subnets for worker nodes
- Security groups restricting access
- No public access to control plane

### Pod Security
- Network policies for pod-to-pod communication
- Service account token mounting
- RBAC for Kubernetes access

## Cost Optimization

- **EKS Control Plane**: ~$70/month
- **EC2 Worker Nodes**: ~$50/month (based on instance types)
- **NAT Gateway**: ~$32/month
- **Load Balancers**: ~$20/month (if used)

## Common Operations

### Scaling Nodes
```bash
# Via Terraform (update desired_size)
terraform apply

# Via eksctl
eksctl scale nodegroup --cluster=cluster-name --nodes=3 main
```

### Updating kubeconfig
```bash
aws eks update-kubeconfig --name cluster-name
```

### Cluster Access
```bash
# Get cluster info
kubectl cluster-info

# List nodes
kubectl get nodes -o wide
```

## Troubleshooting

### Common Issues
- **Node group creation fails**: Check IAM permissions
- **Pods stuck in pending**: Check security groups and subnets
- **kubectl connection fails**: Update kubeconfig

### Debugging Commands
```bash
# Check cluster status
aws eks describe-cluster --name cluster-name

# Check node group status
aws eks describe-nodegroup --cluster-name cluster-name --nodegroup-name main

# Check VPC/subnet configuration
aws ec2 describe-subnets --subnet-ids subnet-12345
```