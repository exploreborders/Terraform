# CI/CD Pipeline with Terraform

This example demonstrates integrating Terraform with GitHub Actions for automated infrastructure deployments. It shows how to create a complete CI/CD pipeline that plans, validates, and applies Terraform changes.

## What You'll Learn

- GitHub Actions workflow configuration
- Automated Terraform planning and applying
- Pull request validation and approval workflows
- State locking in CI/CD environments
- Credential management for automated deployments
- Branch protection and deployment strategies

## Pipeline Features

### Automated Validation
- Terraform format checking (`terraform fmt`)
- Validation (`terraform validate`)
- Security scanning with Checkov
- Cost estimation with Infracost

### Pull Request Workflow
- Plan changes on PR creation
- Comment plan output on PR
- Require approval for production deployments
- Automated cleanup of PR deployments

### Deployment Strategies
- Manual approval for production
- Automated deployment to development
- Staging environment promotion
- Rollback capabilities

## Prerequisites

- GitHub repository with Actions enabled
- AWS credentials stored as GitHub Secrets
- Branch protection rules configured
- Terraform Cloud account (optional, for remote runs)

## Files Overview

- `.github/workflows/` - GitHub Actions workflows
- `terraform/` - Terraform configuration directory
- `scripts/` - Helper scripts for CI/CD
- `docs/` - Pipeline documentation

## Setup Process

### 1. Create GitHub Repository
```bash
# Initialize git repo if not already done
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-org/your-repo.git
git push -u origin main
```

### 2. Configure GitHub Secrets
Go to repository Settings > Secrets and variables > Actions:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `TF_API_TOKEN` (for Terraform Cloud)

### 3. Configure Branch Protection
Settings > Branches > Add rule:
- Branch name pattern: `main`
- Require pull request reviews
- Require status checks: `terraform-plan`, `terraform-validate`

### 4. Push Changes
```bash
git add .
git commit -m "Add CI/CD pipeline"
git push
```

## Workflow Overview

### Pull Request Flow
1. **PR Created**: Runs terraform plan, posts results as comment
2. **PR Approved**: Allows merge to main
3. **Merge to Main**: Triggers production deployment

### Manual Deployment
- Use workflow dispatch for manual deployments
- Select environment (dev/staging/prod)
- Manual approval for production

## Security Best Practices

### Credential Management
- Use OIDC for AWS access (preferred)
- Rotate secrets regularly
- Least-privilege IAM roles

### Pipeline Security
- Scan for vulnerabilities
- Review plan outputs before approval
- Audit trail of all deployments

### State Management
- Remote state with locking
- Encrypted state files
- Access controls for state

## Cost Optimization

### CI/CD Costs
- GitHub Actions: 2000 free minutes/month
- AWS resources: Only during testing
- Terraform Cloud: Free for small teams

### Infrastructure Costs
- Ephemeral environments for testing
- Auto-cleanup of test resources
- Cost monitoring integration

## Troubleshooting

### Common Issues
- **Workflow doesn't trigger**: Check branch protection rules
- **AWS access denied**: Verify IAM permissions and OIDC setup
- **State locking errors**: Check for concurrent runs

### Debugging Workflows
```bash
# Check workflow status
gh workflow list

# View workflow logs
gh run list
gh run view <run-id>
```

### Local Testing
```bash
# Test workflow locally
act -j terraform-plan

# Test with secrets
act -j terraform-plan --secret-file .secrets
```