package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestECSFargateALBProvisioning(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// Path to where your Terraform code is located
		TerraformDir: "..",
	}

	// Cleanup resources at the end
	defer terraform.Destroy(t, terraformOptions)

	// Run init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Validate ALB output
	albURL := terraform.Output(t, terraformOptions, "app_url")
	assert.NotEmpty(t, albURL, "ALB URL should not be empty")

	// Test High Availability
	subnetIDs := terraform.OutputList(t, terraformOptions, "alb_subnet_ids")
	assert.Len(t, subnetIDs, 2, "There should be two subnets for high availability")
}
