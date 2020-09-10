package test

import (
	"github.com/gruntwork-io/terratest/modules/azure"
	"os"
	"testing"
)

const ArmClientId = "ARM_CLIENT_ID"
const ArmClientSecret = "ARM_CLIENT_SECRET"
const ArmSubscriptionId = "ARM_SUBSCRIPTION_ID"
const ArmTenantId = "ARM_TENANT_ID"
const AzureSubscriptionId = "AZURE_SUBSCRIPTION_ID"
const AzureClientSecret = "AZURE_CLIENT_SECRET"
const ApexDomain = "TFVAR_APEX_DOMAIN_NAME"
const ApexDomainResourceGroup = "TFVAR_APEX_DOMAIN_RESOURCE_GROUP_NAME"
const verifyKeyVaultDockerImage = "VERIFY_KEY_VAULT_IMAGE_NAME"

var requiredAzureEnvVars = []string{
	AzureClientSecret,
	AzureSubscriptionId,
	azure.AuthFromEnvClient,
	azure.AuthFromEnvTenant,
}

func checkAzureEnvVars(t *testing.T, additionalEnvVars []string) {
	for _, e := range append(requiredAzureEnvVars, additionalEnvVars...) {
		if os.Getenv(e) == "" {
			t.Fatalf("Missing required environment variable %s", e)
		}
	}
}

func getTerraformEnvVars() map[string]string {
	return map[string]string{
		ArmClientId:       os.Getenv(azure.AuthFromEnvClient),
		ArmClientSecret:   os.Getenv(AzureClientSecret),
		ArmSubscriptionId: os.Getenv(AzureSubscriptionId),
		ArmTenantId:       os.Getenv(azure.AuthFromEnvTenant),
	}
}
