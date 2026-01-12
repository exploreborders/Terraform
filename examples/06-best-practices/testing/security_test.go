package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestSecurityGroupModule tests security group creation and validation
func TestSecurityGroupModule_BasicConfiguration(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../examples/02-resources/ec2-instance",
		Vars: map[string]interface{}{
			"aws_region":            getAwsRegion(),
			"instance_name":         fmt.Sprintf("test-sg-instance-%s", createUniqueId()),
			"instance_type":         "t2.micro",
			"environment":           "test",
			"allowed_ssh_cidrs":     []string{"10.0.0.0/8"},
			"create_state_bucket":   false,
			"create_lock_table":     false,
			"state_bucket_name":     fmt.Sprintf("test-state-%s", createUniqueId()),
			"lock_table_name":       fmt.Sprintf("test-lock-%s", createUniqueId()),
			"example_bucket_name":   fmt.Sprintf("test-example-%s", createUniqueId()),
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate security group was created
	sgId := terraform.Output(t, terraformOptions, "security_group_id")
	assert.NotEmpty(t, sgId)

	// Validate instance was created with security group
	instanceId := terraform.Output(t, terraformOptions, "instance_id")
	assert.NotEmpty(t, instanceId)
}

// TestSecurityGroupModule_RestrictedAccess tests security group with restricted access
func TestSecurityGroupModule_RestrictedAccess(t *testing.T) {
	t.Parallel()

	// Use a very restrictive CIDR that shouldn't match any real access
	restrictedCidr := "192.168.255.0/32"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../examples/02-resources/ec2-instance",
		Vars: map[string]interface{}{
			"aws_region":            getAwsRegion(),
			"instance_name":         fmt.Sprintf("test-sg-restricted-%s", createUniqueId()),
			"instance_type":         "t2.micro",
			"environment":           "test",
			"allowed_ssh_cidrs":     []string{restrictedCidr},
			"create_state_bucket":   false,
			"create_lock_table":     false,
			"state_bucket_name":     fmt.Sprintf("test-state-%s", createUniqueId()),
			"lock_table_name":       fmt.Sprintf("test-lock-%s", createUniqueId()),
			"example_bucket_name":   fmt.Sprintf("test-example-%s", createUniqueId()),
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate security group exists
	sgId := terraform.Output(t, terraformOptions, "security_group_id")
	assert.NotEmpty(t, sgId)

	// In a real test, you might want to verify the security group rules
	// For now, we just ensure the configuration applies successfully
}

// TestSecurityGroupModule_MultipleRules tests security group with multiple ingress rules
func TestSecurityGroupModule_MultipleRules(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../../examples/02-resources/ec2-instance",
		Vars: map[string]interface{}{
			"aws_region":            getAwsRegion(),
			"instance_name":         fmt.Sprintf("test-sg-multi-%s", createUniqueId()),
			"instance_type":         "t2.micro",
			"environment":           "test",
			"allowed_ssh_cidrs":     []string{"10.0.0.0/8", "172.16.0.0/12"},
			"create_state_bucket":   false,
			"create_lock_table":     false,
			"state_bucket_name":     fmt.Sprintf("test-state-%s", createUniqueId()),
			"lock_table_name":       fmt.Sprintf("test-lock-%s", createUniqueId()),
			"example_bucket_name":   fmt.Sprintf("test-example-%s", createUniqueId()),
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate configuration applies with multiple CIDR blocks
	sgId := terraform.Output(t, terraformOptions, "security_group_id")
	assert.NotEmpty(t, sgId)
}