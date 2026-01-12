# Advanced Scenarios

This section explores Terraform's advanced capabilities and real-world boundaries.
These examples demonstrate complex, production-grade scenarios that push Terraform's limits.

## Key Concepts

### Multi-Cloud Deployments
- **Purpose**: Deploy infrastructure across multiple cloud providers
- **Benefits**: Disaster recovery, cost optimization, compliance
- **Challenges**: Provider-specific features, state management, networking

### Kubernetes Integration
- **Purpose**: Infrastructure provisioning for Kubernetes clusters
- **Benefits**: GitOps workflows, infrastructure as code for K8s
- **Challenges**: Cluster lifecycle, worker node management, networking

### CI/CD Integration
- **Purpose**: Automate Terraform deployments in pipelines
- **Benefits**: Consistent deployments, policy enforcement, audit trails
- **Challenges**: State locking, credential management, approval workflows

### Exploring Boundaries
- **Purpose**: Understand Terraform's limits and best practices
- **Benefits**: Know when to split configurations, performance optimization
- **Challenges**: Large state files, complex expressions, resource limits

## Examples Included

### 1. Multi-Cloud (`multi-cloud/`)
- Resources across AWS and GCP
- Cross-cloud networking considerations
- State management for multi-provider setups

### 2. Kubernetes (`kubernetes/`)
- EKS cluster with managed node groups
- VPC integration and security groups
- Cluster add-ons and IAM roles

### 3. CI/CD Pipeline (`ci-cd/`)
- GitHub Actions workflow for Terraform
- Automated testing and validation
- Deployment approvals and rollbacks

### 4. Boundaries (`boundaries/`)
- Large-scale infrastructure patterns
- Complex expressions and dynamic configurations
- Performance optimization techniques

## Prerequisites

### Multi-Cloud
- AWS CLI configured
- GCP project and credentials
- Multi-cloud networking knowledge

### Kubernetes
- AWS CLI configured with EKS permissions
- kubectl installed
- Docker knowledge for container workloads

### CI/CD
- GitHub repository
- GitHub Actions enabled
- Branch protection rules configured

### Boundaries
- Understanding of Terraform limitations
- Large-scale infrastructure experience
- Performance monitoring tools

## Getting Started

### Multi-Cloud Deployment
```bash
cd examples/05-advanced/multi-cloud
terraform init
terraform plan
terraform apply
```

### Kubernetes Cluster
```bash
cd ../kubernetes
terraform init
terraform plan
terraform apply
# Configure kubectl
aws eks update-kubeconfig --name $(terraform output cluster_name)
```

### CI/CD Setup
```bash
cd ../ci-cd
# Follow GitHub Actions setup instructions
```

### Boundaries Exploration
```bash
cd ../boundaries
terraform init
terraform plan
# Monitor performance and resource counts
```

## Advanced Patterns

### Multi-Provider State Management
```hcl
terraform {
  backend "s3" {
    # Single state file for all providers
  }
}
```

### Kubernetes Cluster Management
```hcl
resource "aws_eks_cluster" "main" {
  # Complex cluster configuration
}
```

### CI/CD Automation
```yaml
# GitHub Actions workflow
- name: Terraform Plan
  run: terraform plan -out=tfplan
```

## Cost Considerations

### Multi-Cloud
- **AWS**: ~$10/month (EC2 + networking)
- **GCP**: ~$5/month (Compute Engine + networking)
- **Cross-cloud**: Data transfer costs

### Kubernetes
- **EKS**: ~$70/month (control plane)
- **EC2**: ~$50/month (worker nodes)
- **Load Balancer**: ~$20/month

### CI/CD
- **GitHub Actions**: 2000 minutes free/month
- **No infrastructure costs**

### Boundaries
- **Large Deployments**: Costs scale with resource count
- **Testing Resources**: Temporary, destroy after testing

## Security Considerations

### Multi-Cloud
- Separate credentials for each provider
- Network security between clouds
- Data encryption at rest/transit

### Kubernetes
- IAM roles for service accounts (IRSA)
- Network policies for pod security
- Secrets management

### CI/CD
- OIDC for secure credential access
- Branch protection and required reviews
- Least-privilege pipeline permissions

### Boundaries
- State file encryption
- Access controls for sensitive data
- Audit logging for compliance

## Performance Optimization

### Large Deployments
- Use `terraform plan -parallelism=N`
- Split large configurations
- Use targeted applies: `terraform apply -target=`

### State Management
- Remote state with locking
- State file size monitoring
- Regular state cleanup

### CI/CD Performance
- Caching Terraform plugins
- Parallel plan/apply operations
- Incremental deployments