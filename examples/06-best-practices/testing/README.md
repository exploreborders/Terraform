# Terraform Module Testing with Terratest

This example demonstrates how to write unit tests for Terraform modules using Terratest. Testing ensures your infrastructure code works correctly and prevents regressions.

## What You'll Learn

- Setting up Terratest for Go-based testing
- Writing unit tests for Terraform modules
- Testing resource creation and validation
- Mocking and cleanup strategies
- Integrating tests into CI/CD pipelines

## Prerequisites

- Go installed (1.19+)
- Terraform installed
- AWS CLI configured with test permissions
- Basic Go programming knowledge

## Files Overview

- `go.mod` - Go module definition
- `vpc_test.go` - Unit tests for VPC module
- `security_test.go` - Security group tests
- `helpers.go` - Test utility functions
- `Makefile` - Test automation commands

## Getting Started

### 1. Initialize Go Module
```bash
go mod init terraform-testing
go mod tidy
```

### 2. Install Terratest
```bash
go get github.com/gruntwork-io/terratest/modules/terraform
```

### 3. Run Tests
```bash
go test -v ./...
```

### 4. Run Specific Test
```bash
go test -v -run TestVpcModule
```

## Test Structure

### Basic Test Pattern
```go
func TestVpcModule(t *testing.T) {
    t.Parallel()

    // Setup test options
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/network",
        Vars: map[string]interface{}{
            "name":       "test-vpc",
            "vpc_cidr":   "10.0.0.0/16",
            "environment": "test",
        },
    }

    // Ensure cleanup
    defer terraform.Destroy(t, terraformOptions)

    // Apply infrastructure
    terraform.InitAndApply(t, terraformOptions)

    // Validate results
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

### Test Organization
- **Unit Tests**: Test individual modules
- **Integration Tests**: Test module combinations
- **End-to-End Tests**: Full infrastructure validation

## Writing Effective Tests

### Test Naming Conventions
```go
func TestVpcModule_BasicConfiguration(t *testing.T)
func TestVpcModule_WithNatGateway(t *testing.T)
func TestVpcModule_MultipleAzs(t *testing.T)
```

### Test Data Management
```go
// Use unique names to avoid conflicts
func uniqueId() string {
    return fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
}
```

### Assertions and Validation
```go
// Test resource existence
vpcId := terraform.Output(t, terraformOptions, "vpc_id")
assert.NotEmpty(t, vpcId)

// Test resource properties
actualCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
assert.Equal(t, "10.0.0.0/16", actualCidr)

// Test AWS resource directly
aws.AssertVpcExists(t, vpcId, region)
```

## Advanced Testing Patterns

### Testing with Dependencies
```go
func TestEksWithVpc(t *testing.T) {
    t.Parallel()

    // First create VPC
    vpcOptions := // ... VPC config

    defer terraform.Destroy(t, vpcOptions)
    terraform.InitAndApply(t, vpcOptions)

    vpcId := terraform.Output(t, vpcOptions, "vpc_id")

    // Then create EKS using VPC
    eksOptions := &terraform.Options{
        TerraformDir: "../examples/kubernetes",
        Vars: map[string]interface{}{
            "vpc_id": vpcId,
            // ... other EKS config
        },
    }

    defer terraform.Destroy(t, eksOptions)
    terraform.InitAndApply(t, eksOptions)

    // Validate EKS cluster
    clusterName := terraform.Output(t, eksOptions, "cluster_name")
    assert.NotEmpty(t, clusterName)
}
```

### Testing Failure Scenarios
```go
func TestVpcModule_InvalidCidr(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/network",
        Vars: map[string]interface{}{
            "vpc_cidr": "invalid-cidr",
        },
    }

    // Expect failure
    _, err := terraform.InitAndPlanE(t, terraformOptions)
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "Invalid CIDR")
}
```

### Performance Testing
```go
func TestLargeDeploymentPerformance(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping performance test in short mode")
    }

    start := time.Now()

    terraformOptions := // ... large deployment config

    terraform.InitAndApply(t, terraformOptions)

    duration := time.Since(start)
    t.Logf("Deployment took %v", duration)

    // Assert reasonable performance
    assert.True(t, duration < 30*time.Minute, "Deployment too slow")
}
```

## Test Utilities and Helpers

### Common Helper Functions
```go
// helpers.go
func CreateRandomVpcName() string {
    return fmt.Sprintf("test-vpc-%s", random.UniqueId())
}

func GetAwsRegion() string {
    region := os.Getenv("AWS_DEFAULT_REGION")
    if region == "" {
        region = "us-east-1"
    }
    return region
}

func AssertVpcExists(t *testing.T, vpcId string, region string) {
    ec2Client := ec2.New(session.Must(session.NewSession()), &aws.Config{Region: aws.String(region)})
    _, err := ec2Client.DescribeVpcs(&ec2.DescribeVpcsInput{VpcIds: []*string{&vpcId}})
    assert.NoError(t, err)
}
```

### Test Configuration Management
```go
// Use environment variables for test configuration
func GetTestConfig() map[string]interface{} {
    return map[string]interface{}{
        "aws_region":    GetAwsRegion(),
        "environment":   "test",
        "instance_type": os.Getenv("TEST_INSTANCE_TYPE"),
    }
}
```

## CI/CD Integration

### GitHub Actions
```yaml
name: 'Terraform Tests'

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Run Tests
        run: go test -v ./examples/06-best-practices/testing/...
```

### Parallel Test Execution
```bash
# Run tests in parallel packages
go test -v ./testing/... -parallel=4

# Run with race detection
go test -v -race ./testing/...
```

## Best Practices for Testing

### Test Organization
- Group related tests in packages
- Use descriptive test names
- Follow Go testing conventions
- Keep tests focused and fast

### Resource Management
- Always use unique resource names
- Clean up resources in defer statements
- Use test timeouts to prevent hanging
- Implement proper error handling

### Test Data
- Use realistic test data
- Avoid hardcoded values
- Generate unique identifiers
- Test edge cases and error conditions

### Performance Considerations
- Run tests in parallel when possible
- Use short mode for quick feedback
- Cache dependencies between runs
- Monitor test execution time

## Troubleshooting Tests

### Common Issues
- **AWS API Limits**: Use different regions or accounts
- **Resource Conflicts**: Use unique names and proper cleanup
- **Timing Issues**: Add retry logic for eventual consistency
- **Permission Errors**: Ensure test IAM roles have required permissions

### Debugging Tests
```bash
# Enable verbose Terraform output
terraformOptions := &terraform.Options{
    TerraformDir: "../modules/network",
    Logger:       logger.Discard, // or use logger.Default for verbose
}

// Check Terraform logs
_, err := terraform.InitAndPlanE(t, terraformOptions)
if err != nil {
    t.Logf("Terraform error: %v", err)
}
```

## Extending the Test Suite

### Adding New Tests
1. Create new test file: `*_test.go`
2. Follow naming conventions
3. Add to CI/CD pipeline
4. Update documentation

### Test Coverage
```bash
# Generate coverage report
go test -coverprofile=coverage.out ./...

# View coverage in browser
go tool cover -html=coverage.out
```

### Integration with Other Tools
- **SonarQube**: Code quality analysis
- **Allure**: Test reporting
- **TestRail/Jira**: Test case management
- **Slack/Teams**: Test result notifications

This testing framework provides a solid foundation for validating your Terraform infrastructure. Start with basic unit tests and gradually add integration and performance tests as your codebase grows.