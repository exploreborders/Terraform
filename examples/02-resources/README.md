# Resource Management Examples

This section demonstrates core resource management concepts in Terraform, focusing on AWS infrastructure components.

## Examples Included

### 1. EC2 Instance (`ec2-instance/`)
- Provisions an EC2 instance with security group
- Demonstrates data sources, lifecycle management, and dependencies
- Includes user data for web server setup

### 2. VPC Network (`vpc-network/`)
- Creates a complete VPC with public/private subnets
- Internet Gateway and NAT Gateway configuration
- Route tables and subnet associations

### 3. RDS Database (`rds-database/`)
- PostgreSQL RDS instance with security groups
- Parameter groups and subnet groups
- Backup and maintenance configuration

## Prerequisites for All Examples

1. **AWS Account**: Active AWS account with appropriate permissions
2. **AWS CLI**: Configured with credentials (`aws configure`)
3. **Terraform**: v1.0+ installed
4. **Permissions**: IAM user/role with EC2, VPC, and RDS permissions

## Getting Started

1. **Configure AWS**:
   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, and region
   ```

2. **Start with VPC** (recommended order):
   ```bash
   cd examples/02-resources/vpc-network
   cp terraform.tfvars.example terraform.tfvars
   terraform init
   terraform plan
   terraform apply
   ```

3. **Then EC2 Instance**:
   ```bash
   cd ../ec2-instance
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your VPC info and IP
   terraform init
   terraform plan
   terraform apply
   ```

4. **Finally RDS**:
   ```bash
   cd ../rds-database
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with VPC ID from step 2
   terraform init
   terraform plan
   terraform apply
   ```

## Cost Considerations

- **EC2 t2.micro**: Eligible for free tier (750 hours/month)
- **NAT Gateway**: ~$0.045/hour + data transfer costs
- **RDS db.t3.micro**: ~$0.017/hour
- **VPC/EIPs**: Minimal costs

Monitor costs in AWS Billing console and clean up resources when done.

## Security Best Practices

- Restrict SSH access to your IP only
- Use IAM roles instead of access keys
- Enable encryption for RDS
- Use private subnets for databases
- Implement least-privilege security groups

## Learning Outcomes

By completing these examples, you'll understand:
- Resource dependencies and ordering
- Cross-resource references
- Security group management
- Network architecture design
- Database provisioning best practices
- Cost optimization strategies