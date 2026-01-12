package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// getAwsRegion returns the AWS region to use for tests
func getAwsRegion() string {
	region := os.Getenv("AWS_DEFAULT_REGION")
	if region == "" {
		region = "us-east-1"
	}
	return region
}

// createUniqueId generates a unique identifier for test resources
func createUniqueId() string {
	return strings.ToLower(random.UniqueId())
}

// TestVpcModule tests the VPC module basic functionality
func TestVpcModule_BasicConfiguration(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../modules/network",
		Vars: map[string]interface{}{
			"name":                fmt.Sprintf("test-vpc-%s", createUniqueId()),
			"vpc_cidr":           "10.0.0.0/16",
			"environment":        "test",
			"public_subnet_cidrs": []string{"10.0.1.0/24", "10.0.2.0/24"},
			"private_subnet_cidrs": []string{"10.0.10.0/24", "10.0.11.0/24"},
			"create_nat_gateway": true,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate VPC creation
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId)

	// Validate VPC CIDR
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	assert.Equal(t, "10.0.0.0/16", vpcCidr)

	// Validate subnet counts
	publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	assert.Len(t, publicSubnetIds, 2)

	privateSubnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	assert.Len(t, privateSubnetIds, 2)

	// Validate IGW exists
	igwId := terraform.Output(t, terraformOptions, "internet_gateway_id")
	assert.NotEmpty(t, igwId)

	// Validate NAT Gateway exists
	natGatewayId := terraform.Output(t, terraformOptions, "nat_gateway_id")
	assert.NotEmpty(t, natGatewayId)

	// Test that VPC actually exists in AWS
	region := getAwsRegion()
	aws.AssertVpcExists(t, vpcId, region)
}

// TestVpcModule_NoNatGateway tests VPC creation without NAT Gateway
func TestVpcModule_NoNatGateway(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../modules/network",
		Vars: map[string]interface{}{
			"name":                fmt.Sprintf("test-vpc-no-nat-%s", createUniqueId()),
			"vpc_cidr":           "10.1.0.0/16",
			"environment":        "test",
			"public_subnet_cidrs": []string{"10.1.1.0/24"},
			"private_subnet_cidrs": []string{"10.1.10.0/24"},
			"create_nat_gateway": false,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate NAT Gateway is null
	natGatewayId := terraform.Output(t, terraformOptions, "nat_gateway_id")
	assert.Empty(t, natGatewayId)
}

// TestVpcModule_InvalidCidr tests validation of invalid CIDR
func TestVpcModule_InvalidCidr(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../modules/network",
		Vars: map[string]interface{}{
			"name":      fmt.Sprintf("test-vpc-invalid-%s", createUniqueId()),
			"vpc_cidr": "invalid-cidr",
		},
	}

	// Expect plan to fail due to validation
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "Invalid CIDR")
}

// TestVpcModule_Tags tests custom tagging functionality
func TestVpcModule_Tags(t *testing.T) {
	t.Parallel()

	customTags := map[string]interface{}{
		"Project":     "terraform-testing",
		"Owner":       "test-user",
		"CostCenter":  "engineering",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../modules/network",
		Vars: map[string]interface{}{
			"name":         fmt.Sprintf("test-vpc-tags-%s", createUniqueId()),
			"vpc_cidr":    "10.2.0.0/16",
			"environment": "test",
			"tags":        customTags,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	region := getAwsRegion()

	// Verify VPC exists and check tags
	vpc := aws.GetVpcById(t, vpcId, region)

	// Check required tags are present
	expectedTags := map[string]string{
		"Name":        fmt.Sprintf("test-vpc-tags-%s-vpc", strings.Split(createUniqueId(), "-")[0]),
		"Environment": "test",
		"ManagedBy":   "Terraform",
		"Module":      "network",
		"Project":     "terraform-testing",
		"Owner":       "test-user",
		"CostCenter":  "engineering",
	}

	for key, expectedValue := range expectedTags {
		actualValue, found := vpc.Tags[key]
		assert.True(t, found, "Tag %s should be present", key)
		assert.Equal(t, expectedValue, actualValue, "Tag %s should have correct value", key)
	}
}