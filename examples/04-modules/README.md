# Terraform Modules and Reusability

This section demonstrates how to create and use reusable Terraform modules.
Modules allow you to package infrastructure components for reuse across projects and environments.

## Module Concepts

### What are Modules?
Modules are containers for multiple resources that are used together.
A module consists of:
- **Root module**: Your main configuration
- **Child modules**: Reusable components called by the root module

### Benefits
- **Code Reuse**: Use the same infrastructure patterns everywhere
- **Maintainability**: Update logic in one place
- **Consistency**: Ensure similar environments use identical configurations
- **Testing**: Test modules independently
- **Collaboration**: Share modules across teams

### Module Sources
- **Local**: `./modules/network`
- **Git**: `git::https://github.com/org/module.git`
- **Terraform Registry**: `source = "terraform-aws-modules/vpc/aws"`
- **HTTP/HTTPS**: Archive URLs

## Examples Included

### 1. Network Module (`modules/network/`)
- Complete VPC module with subnets, gateways, and route tables
- Highly configurable with validation
- Production-ready with best practices

### 2. Multi-Environment (`examples/04-modules/multi-environment/`)
- Uses the network module across dev/staging/prod
- Demonstrates module reuse with different configurations
- Shows workspace integration with modules

### 3. Advanced Networking (`examples/04-modules/advanced-networking/`)
- Complex network topologies using modules
- Module composition (modules calling other modules)
- Conditional module usage

## Module Structure Best Practices

```
modules/
└── network/
    ├── main.tf          # Resources
    ├── variables.tf     # Inputs
    ├── outputs.tf       # Outputs
    ├── README.md        # Documentation
    └── versions.tf      # Provider requirements
```

## When to Use Modules

**Create modules for:**
- Infrastructure patterns used in multiple places
- Complex resource groups (VPC, ECS cluster, etc.)
- Team-shared components
- Published reusable components

**Don't create modules for:**
- Single-use resources
- Environment-specific configurations
- Overly complex abstractions

## Getting Started

1. **Examine the Network Module**:
   ```bash
   cd modules/network
   cat README.md
   ```

2. **Use in Multi-Environment Example**:
   ```bash
   cd ../../examples/04-modules/multi-environment
   terraform init
   terraform plan
   terraform apply
   ```

3. **Explore Advanced Usage**:
   ```bash
   cd ../advanced-networking
   terraform init
   terraform plan
   ```

## Module Development Workflow

1. **Design**: Identify reusable infrastructure patterns
2. **Create**: Write module with clear inputs/outputs
3. **Test**: Test module independently
4. **Document**: Add comprehensive README
5. **Version**: Use Git tags for versioning
6. **Publish**: Share via Git or Terraform Registry