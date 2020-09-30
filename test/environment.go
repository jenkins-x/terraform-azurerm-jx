package test

import (
	"context"
	"github.com/gruntwork-io/terratest/modules/azure"
	"os"
	"strconv"
	"testing"
	"time"
)

const ArmClientId = "ARM_CLIENT_ID"
const ArmClientSecret = "ARM_CLIENT_SECRET"
const ArmSubscriptionId = "ARM_SUBSCRIPTION_ID"
const ArmTenantId = "ARM_TENANT_ID"
const AzureSubscriptionId = "AZURE_SUBSCRIPTION_ID"
const AzureClientSecret = "AZURE_CLIENT_SECRET"
const ApexDomain = "TFVAR_APEX_DOMAIN_NAME"
const ApexDomainResourceGroup = "TFVAR_APEX_DOMAIN_RESOURCE_GROUP_NAME"
const AzureLocation = "TFVAR_AZURE_LOCATION"
const verifyKeyVaultDockerImage = "VERIFY_KEY_VAULT_IMAGE_NAME"
const AzureRmTimeout = "AZURE_RM_TIMEOUT"
const KubernetesTimeout = "KUBERNETES_TIMEOUT"

const AzureDefaultLocation = "australiaeast"
const defaultTimeOut = 300

var requiredAzureEnvVars = []string{
	AzureClientSecret,
	AzureSubscriptionId,
	azure.AuthFromEnvClient,
	azure.AuthFromEnvTenant,
}

func getDefaultAzureLocation() string {
	value := os.Getenv(AzureLocation)
	if len(value) == 0 {
		return AzureDefaultLocation
	}
	return value
}

func generateDefaultContext(envTimeoutVariable string) context.Context {
	timeOut := int64(defaultTimeOut)
	value := os.Getenv(envTimeoutVariable)
	if len(value) != 0 {
		valueInt, err := strconv.ParseInt(value, 10, 32)
		if err != nil {
			timeOut = valueInt
		}
	}
	ctx, _ := context.WithTimeout(context.Background(), time.Duration(timeOut)*time.Second)
	return ctx
}

func getAzureRmTimeout() time.Duration {
	defaultTimeout := 60 * time.Second
	value := os.Getenv(AzureRmTimeout)
	if len(value) == 0 {
		return defaultTimeout
	}
	valueInt, err := strconv.ParseInt(value, 10, 32)
	if err != nil {
		return defaultTimeout
	}
	return time.Duration(valueInt) * time.Second
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
