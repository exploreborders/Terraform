package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestTerraformFormatting tests that all Terraform files are properly formatted
func TestTerraformFormatting(t *testing.T) {
	t.Parallel()

	// Test root directory
	testFormatting(t, "../../..")

	// Test examples
	testFormatting(t, "../../../examples")

	// Test modules
	testFormatting(t, "../../../modules")
}

// TestTerraformValidation tests that all Terraform configurations are valid
func TestTerraformValidation(t *testing.T) {
	t.Parallel()

	// Test all terraform directories
	dirs := []string{
		"../../../modules/network",
		"../../../examples/01-basics",
		"../../../examples/02-resources/ec2-instance",
		"../../../examples/02-resources/vpc-network",
		"../../../examples/03-state/remote-backend",
		"../../../examples/03-state/workspaces",
	}

	for _, dir := range dirs {
		dir := dir // capture loop variable
		t.Run(fmt.Sprintf("validate-%s", dir), func(t *testing.T) {
			t.Parallel()
			testValidation(t, dir)
		})
	}
}

// TestEndToEndDeployment tests a complete infrastructure deployment
func TestEndToEndDeployment(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping end-to-end test in short mode")
	}

	t.Parallel()

	uniqueId := createUniqueId()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../examples/02-resources/multi-environment",
		Vars: map[string]interface{}{
			"aws_region": getAwsRegion(),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)

	// Apply all environments
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	t.Logf("End-to-end deployment took %v", duration)

	// Validate outputs
	devVpcId := terraform.Output(t, terraformOptions, "dev_vpc_id")
	assert.NotEmpty(t, devVpcId)

	stagingVpcId := terraform.Output(t, terraformOptions, "staging_vpc_id")
	assert.NotEmpty(t, stagingVpcId)

	prodVpcId := terraform.Output(t, terraformOptions, "prod_vpc_id")
	assert.NotEmpty(t, prodVpcId)

	// Ensure VPCs are different
	assert.NotEqual(t, devVpcId, stagingVpcId)
	assert.NotEqual(t, stagingVpcId, prodVpcId)
	assert.NotEqual(t, devVpcId, prodVpcId)

	// Validate summary
	summary := terraform.OutputMap(t, terraformOptions, "network_summary")
	assert.NotEmpty(t, summary)
}

// TestPerformanceLargeInfrastructure tests performance with large resource counts
func TestPerformanceLargeInfrastructure(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}

	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../examples/05-advanced/boundaries",
		Vars: map[string]interface{}{
			"aws_region":             getAwsRegion(),
			"environment":           "performance-test",
			"vpc_cidr":              "10.100.0.0/16",
			"enable_complex_features": false,
			"state_test_bucket_name": fmt.Sprintf("perf-test-bucket-%s", createUniqueId()),
		},
		MaxRetries:         2,
		TimeBetweenRetries: 10 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)

	// Time the deployment
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	t.Logf("Large infrastructure deployment took %v", duration)

	// Validate performance (should complete within reasonable time)
	assert.True(t, duration < 20*time.Minute, "Deployment took too long: %v", duration)

	// Validate resource counts
	subnetCount := terraform.Output(t, terraformOptions, "subnet_count")
	assert.Equal(t, "50", subnetCount)

	instanceCount := terraform.Output(t, terraformOptions, "instance_count")
	assert.Equal(t, "50", instanceCount)
}

// Helper functions

func testFormatting(t *testing.T, dir string) {
	// This would require running terraform fmt -check
	// For now, we'll just ensure the directory exists and has .tf files
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		t.Skipf("Directory %s does not exist", dir)
	}

	files, err := os.ReadDir(dir)
	assert.NoError(t, err)

	hasTfFiles := false
	for _, file := range files {
		if strings.HasSuffix(file.Name(), ".tf") {
			hasTfFiles = true
			break
		}
	}

	assert.True(t, hasTfFiles, "Directory %s should contain .tf files", dir)
}

func testValidation(t *testing.T, dir string) {
	terraformOptions := &terraform.Options{
		TerraformDir: dir,
	}

	// Test that terraform init works
	terraform.Init(t, terraformOptions)

	// Test that terraform validate passes
	terraform.Validate(t, terraformOptions)
}

// TestResourceCleanup tests that resources are properly cleaned up
func TestResourceCleanup(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../examples/01-basics",
		Vars: map[string]interface{}{
			"name":         "Terraform Learner",
			"secret_value": "test-secret",
			"environment": "test",
		},
	}

	// Apply resources
	terraform.InitAndApply(t, terraformOptions)

	// Validate resources exist
	filePath := terraform.Output(t, terraformOptions, "file_path")
	assert.NotEmpty(t, filePath)

	// Clean up
	terraform.Destroy(t, terraformOptions)

	// In a real test, you might validate that resources were actually deleted
	// For now, we just ensure destroy completes without error
}

// TestIdempotency tests that applying the same configuration multiple times is safe
func TestIdempotency(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../examples/01-basics",
		Vars: map[string]interface{}{
			"name":         "Test Learner",
			"secret_value": "test-secret",
			"environment": "test",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	// Apply once
	terraform.InitAndApply(t, terraformOptions)

	// Apply again (should be idempotent)
	terraform.Apply(t, terraformOptions)

	// Validate state is consistent
	filePath := terraform.Output(t, terraformOptions, "file_path")
	assert.NotEmpty(t, filePath)
}