# 🚀 Terraform Learning Repository

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![Go](https://img.shields.io/badge/go-%2300ADD8.svg?style=for-the-badge&logo=go&logoColor=white)](https://golang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive, hands-on learning environment for mastering Terraform infrastructure as code. This repository provides a complete curriculum from basics to advanced enterprise patterns, with practical examples, automated testing, and production-ready best practices.

## 📚 What is Terraform?

Terraform is HashiCorp's infrastructure as code tool that lets you define, provision, and manage cloud infrastructure using declarative configuration files. It supports 100+ providers including AWS, Azure, GCP, and Kubernetes.

### 🎯 When to Use Terraform

**Perfect for:**
- ✅ Cloud infrastructure provisioning and management
- ✅ Multi-cloud and hybrid cloud deployments
- ✅ Infrastructure automation and versioning
- ✅ Team collaboration with shared infrastructure code
- ✅ Immutable infrastructure and blue-green deployments

**Not ideal for:**
- ❌ Application runtime configuration (use Ansible/Puppet)
- ❌ Database schema migrations
- ❌ Application deployment (use Kubernetes/Helm)
- ❌ Ephemeral resources (use containers)

## 🗺️ Learning Path

This repository follows a structured, progressive learning journey with 50+ examples:

| Section | Focus | Difficulty | Time | Examples |
|---------|-------|------------|------|----------|
| **1. Setup & Fundamentals** | Basic concepts, local provider | 🟢 Beginner | 1-2 hours | 3 examples |
| **2. Resource Management** | AWS infrastructure provisioning | 🟡 Intermediate | 2-3 hours | 3 examples |
| **3. State & Collaboration** | Remote state, workspaces, locking | 🟡 Intermediate | 2-3 hours | 2 examples |
| **4. Modules & Reusability** | Modular design, reusability | 🟠 Advanced | 3-4 hours | 3 examples |
| **5. Advanced Scenarios** | Multi-cloud, Kubernetes, CI/CD | 🔴 Expert | 4-6 hours | 4 examples |
| **6. Best Practices & Testing** | Production patterns, testing | 🔴 Expert | 3-4 hours | 2 frameworks |

## 🏗️ Repository Structure

```
terraform-learning/
├── 📁 examples/                    # Hands-on examples by topic
│   ├── 01-basics/                 # Fundamentals (local provider)
│   │   └── main.tf, variables.tf, outputs.tf, README.md
│   ├── 02-resources/              # AWS resource management
│   │   ├── ec2-instance/          # EC2 with security groups
│   │   ├── vpc-network/           # VPC, subnets, gateways
│   │   └── rds-database/          # RDS with networking
│   ├── 03-state/                  # State management
│   │   ├── remote-backend/        # S3 + DynamoDB backend
│   │   └── workspaces/            # Environment isolation
│   ├── 04-modules/                # Modular architecture
│   │   ├── multi-environment/     # Module reuse across envs
│   │   └── advanced-networking/   # Complex module patterns
│   ├── 05-advanced/               # Enterprise scenarios
│   │   ├── multi-cloud/           # AWS + GCP infrastructure
│   │   ├── kubernetes/            # EKS cluster management
│   │   ├── ci-cd/                 # GitHub Actions pipeline
│   │   └── boundaries/            # Performance & limits testing
│   └── 06-best-practices/         # Production excellence
│       ├── testing/               # Terratest framework (Go)
│       └── security/              # Security implementation
├── 📁 modules/                     # Reusable Terraform modules
│   └── network/                   # VPC networking module
│       ├── main.tf, variables.tf, outputs.tf, README.md
├── 📁 docs/                        # Documentation
│   └── best-practices.md          # Comprehensive guide
├── 🔧 venv/                        # Python virtual environment
│   └── bin/terraform              # Terraform binary
├── 🧪 .github/workflows/           # CI/CD automation
├── 📝 README.md                    # This file
└── 🔒 .gitignore                   # Security-conscious ignores
```

## 🚀 Quick Start

### Prerequisites
- **Terraform** v1.14.3+ ([install](https://terraform.io/downloads))
- **AWS CLI** configured ([setup](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html))
- **Git** for version control
- **Go** 1.21+ (for testing examples)

### Basic Usage
```bash
# Clone the repository
git clone https://github.com/your-org/terraform-learning.git
cd terraform-learning

# Activate Terraform environment
source venv/bin/activate

# Start with basics
cd examples/01-basics
terraform init
terraform plan
terraform apply

# Clean up when done
terraform destroy
```

### Advanced Setup with Testing
```bash
# Create Python environment for tooling
python3 -m venv venv
source venv/bin/activate

# Terraform is installed in venv/bin/terraform
terraform version

# Run comprehensive test suite
cd examples/06-best-practices/testing
make deps
make test
```

## 🎯 Learning Outcomes

By completing this repository, you'll master:

- **Infrastructure as Code**: Write, test, and deploy production infrastructure
- **Cloud Architecture**: Design scalable, secure AWS infrastructure
- **DevOps Practices**: Implement CI/CD, testing, and collaboration workflows
- **Enterprise Patterns**: Apply production-ready best practices and security
- **Advanced Features**: Use modules, remote state, workspaces, and multi-cloud
- **Testing & Quality**: Write automated tests with Terratest framework

## 🛠️ Key Features

### ✅ Complete Curriculum
- **50+ practical examples** and configurations
- **Progressive difficulty** from basics to enterprise
- **Real-world scenarios** with production considerations

### 🧪 Comprehensive Testing
- **Terratest integration** for Go-based testing
- **Unit, integration, and performance tests**
- **CI/CD pipeline examples** with GitHub Actions
- **Automated test execution** with Makefiles

### 🔒 Security First
- **No hardcoded secrets** or credentials
- **AWS security best practices** implementation
- **Encryption, access control, and compliance**
- **Security testing and validation**

### 📚 Rich Documentation
- **Comprehensive READMEs** for each section
- **Inline code comments** and explanations
- **Best practices guide** (150+ pages)
- **Troubleshooting guides** and examples

### 🏢 Enterprise Ready
- **Modular, reusable components**
- **Remote state management** with locking
- **Multi-environment support** with workspaces
- **Cost optimization** and monitoring patterns

## 💰 Cost Considerations

Most examples use AWS Free Tier resources:

| Resource | Free Tier | Monthly Cost |
|----------|-----------|--------------|
| **EC2 t2.micro** | 750 hours | Free |
| **RDS db.t3.micro** | Limited | ~$12 |
| **S3, VPC, IAM** | Always free | Free |
| **NAT Gateway** | None | ~$32 |
| **EKS Control Plane** | None | ~$70 |

**Estimated costs for full exploration:**
- Basic examples: **Free**
- Resource management: **$5-15/month**
- Advanced scenarios: **$20-50/month**
- **Always run `terraform destroy`** to avoid charges

## 🤝 Contributing

We welcome contributions! This is a learning repository designed for community improvement.

### Ways to Contribute
- 🐛 **Bug Reports**: Found an issue? [Open an issue](issues)
- 📝 **Documentation**: Improve guides or add examples
- 🧪 **Testing**: Add test cases or CI improvements
- 💡 **Features**: Suggest new examples or sections
- 📚 **Education**: Help others learn Terraform

### Contribution Guidelines
1. Follow established structure and naming conventions
2. Include comprehensive documentation and examples
3. Add tests for new functionality
4. Update relevant README files
5. Follow Terraform and Go best practices

### Development Setup
```bash
# Fork and clone
git clone https://github.com/your-username/terraform-learning.git

# Create feature branch
git checkout -b feature/new-example

# Make changes and test
terraform fmt
terraform validate

# Submit pull request
git push origin feature/new-example
```

## 📖 Resources & Further Reading

### Official Documentation
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws)

### Learning Platforms
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform Certification](https://www.hashicorp.com/certification/terraform-associate)
- [AWS Terraform Workshops](https://aws-samples.github.io/)

### Community
- [Terraform Forum](https://discuss.hashicorp.com/c/terraform-core)
- [Terraform Discord](https://discord.gg/hashicorp)
- [r/Terraform](https://reddit.com/r/Terraform)

### Best Practices
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Infrastructure as Code Best Practices](https://www.hashicorp.com/resources/infrastructure-as-code-best-practices)

## 📄 License

This repository is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **HashiCorp** for Terraform and the amazing ecosystem
- **AWS** for cloud infrastructure and Free Tier
- **Terratest** community for testing frameworks
- **Open source contributors** who make learning accessible

---

**Happy Terraforming!** 🏗️✨

*Built with ❤️ for the DevOps and infrastructure community*