# Terraform Best Practices Guide

## Overview

This comprehensive guide covers production-ready best practices for Terraform infrastructure as code. Implementing these practices ensures secure, maintainable, and scalable infrastructure deployments.

## 1. Project Structure and Organization

### Directory Structure
```
terraform-project/
├── main.tf                 # Primary resources
├── variables.tf           # Input variables
├── outputs.tf            # Output values
├── terraform.tfvars      # Variable values (gitignored)
├── versions.tf           # Provider and Terraform versions
├── README.md             # Documentation
├── .gitignore            # Ignore sensitive files
├── modules/              # Reusable modules
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
└── examples/             # Usage examples
    └── basic-deployment/
```

### File Naming Conventions
- Use lowercase with hyphens: `main.tf`, `variables.tf`
- Prefix related files consistently
- Use descriptive names: `network-security.tf` vs `sec.tf`

## 2. State Management

### Remote State Best Practices
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### State Management Rules
- **Always use remote state** for team environments
- **Enable state locking** to prevent concurrent modifications
- **Encrypt state files** at rest
- **Backup state files** regularly
- **Never edit state manually** (use `terraform state` commands)

### State Commands
```bash
# Move resources between states
terraform state mv aws_instance.old aws_instance.new

# Remove orphaned resources
terraform state rm aws_instance.removed

# List all resources in state
terraform state list

# Show resource details
terraform state show aws_instance.example
```

## 3. Security Best Practices

### Secret Management
```hcl
# ❌ Never do this
variable "db_password" {
  default = "super-secret-password"
}

# ✅ Use external secret management
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_id
}

# Or use environment variables
variable "db_password" {
  type = string
  sensitive = true
}
```

### Access Control
- **Use IAM roles** instead of access keys
- **Implement least privilege** access
- **Enable MFA** for all accounts
- **Regular credential rotation**

### Network Security
```hcl
# Restrict security group access
resource "aws_security_group" "web" {
  name_prefix = "web-sg-"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Internal network only
  }

  # Minimal egress rules
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## 4. Code Quality and Standards

### Formatting and Validation
```bash
# Format all files
terraform fmt -recursive

# Validate configuration
terraform validate

# Check for issues
terraform plan -detailed-exitcode
```

### Naming Conventions
```hcl
# Resources
resource "aws_instance" "web_server" {
  # Good: descriptive and consistent
}

resource "aws_instance" "web" {
  # Bad: too generic
}

# Variables
variable "vpc_cidr_block" {
  # Good: clear purpose
}

variable "cidr" {
  # Bad: ambiguous
}

# Locals
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}
```

### Documentation Standards
```hcl
variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be a valid IPv4 CIDR block between /16 and /24."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}
```

## 5. Module Development

### Module Structure
```hcl
# versions.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}
```

### Module Best Practices
- **Single responsibility** per module
- **Version your modules** using Git tags
- **Document all inputs and outputs**
- **Include examples** in module repositories
- **Test modules independently**

### Module Usage
```hcl
module "vpc" {
  source = "git::https://github.com/org/terraform-aws-vpc.git?ref=v1.0.0"

  name = "production"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.common_tags
}
```

## 6. Testing Strategies

### Unit Testing with Terratest
```go
func TestTerraformAwsVpc(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic-vpc",
    }

    defer terraform.Destroy(t, terraformOptions)

    terraform.InitAndApply(t, terraformOptions)

    vpcID := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcID)
}
```

### Integration Testing
- Test complete infrastructure deployments
- Validate cross-resource dependencies
- Test failure scenarios and recovery

### Policy Testing
```bash
# Use Checkov for policy testing
checkov -f main.tf --framework terraform

# Use Terraform Sentinel (TFC/E only)
# Policy as code for infrastructure
```

## 7. CI/CD Integration

### GitHub Actions Example
```yaml
name: 'Terraform CI/CD'

on:
  pull_request:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.14.3"

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -no-color
        continue-on-error: true

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

### Branch Protection
- Require pull request reviews
- Require status checks to pass
- Restrict pushes to main branch
- Require linear history

## 8. Performance Optimization

### Resource Optimization
```hcl
# Use data sources for read-only operations
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Minimize resource dependencies
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Only depend on necessary resources
  vpc_security_group_ids = [aws_security_group.web.id]
}
```

### Execution Optimization
```bash
# Increase parallelism for large deployments
terraform apply -parallelism=30

# Target specific resources for faster iteration
terraform apply -target=aws_instance.web

# Skip refresh for known-good states
terraform plan -refresh=false
```

## 9. Cost Management

### Cost Optimization Patterns
```hcl
# Use spot instances for non-critical workloads
resource "aws_instance" "worker" {
  instance_type = "m5.large"
  instance_market_options {
    market_type = "spot"
  }
}

# Implement auto-scaling
resource "aws_autoscaling_group" "web" {
  min_size         = 1
  max_size         = 10
  desired_capacity = 2

  # Scale based on demand
  # ...
}
```

### Cost Monitoring
- Use AWS Cost Explorer
- Set up billing alerts
- Implement cost allocation tags
- Regular cost reviews

## 10. Monitoring and Alerting

### Infrastructure Monitoring
```hcl
# Enable CloudWatch monitoring
resource "aws_instance" "web" {
  monitoring = true

  tags = {
    Environment = var.environment
    Application = "web"
  }
}

# Create CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
}
```

### Terraform Monitoring
- Use Terraform Cloud/Enterprise for run monitoring
- Implement drift detection
- Monitor state file changes
- Audit all Terraform operations

## 11. Disaster Recovery

### Backup Strategies
```bash
# Backup state files
aws s3 cp terraform.tfstate s3://backups/$(date +%Y%m%d-%H%M%S)-terraform.tfstate

# Enable versioning
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### Recovery Procedures
1. Identify the issue
2. Restore from backup if needed
3. Use `terraform refresh` to sync state
4. Apply fixes incrementally
5. Test thoroughly before production

## 12. Compliance and Governance

### Policy as Code
```bash
# Use Sentinel policies (TFC/E)
# Example: Require encryption

# Use OPA/Rego for policy checking
# Example: Security group rules must not allow 0.0.0.0/0
```

### Audit and Compliance
- Maintain detailed deployment logs
- Regular security assessments
- Compliance reporting automation
- Access review processes

## 13. Team Collaboration

### Code Review Checklist
- [ ] Terraform formatting applied
- [ ] No hardcoded secrets
- [ ] Variables properly typed and documented
- [ ] Resources have appropriate tags
- [ ] Remote state configured
- [ ] Tests included and passing
- [ ] Documentation updated

### Knowledge Sharing
- Regular team training sessions
- Shared module repositories
- Internal best practice guides
- Cross-team code reviews

## 14. Maintenance and Updates

### Regular Maintenance Tasks
- Update Terraform and provider versions
- Review and update access policies
- Clean up unused resources
- Update documentation

### Version Management
```hcl
# Pin provider versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0, < 2.0.0"
}
```

### Dependency Management
- Monitor for deprecated resources
- Plan for breaking changes
- Test upgrades in development first
- Maintain upgrade runbooks

This guide provides a foundation for implementing production-ready Terraform practices. Adapt these recommendations to your organization's specific needs and continuously improve your processes.