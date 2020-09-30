package test

import (
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/preview/containerregistry/runtime/2019-08-15-preview/containerregistry"
	"github.com/Azure/go-autorest/autorest"
	"github.com/Azure/go-autorest/autorest/adal"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"os"
	"testing"
)

func TestTerraformJxClusterWithContainerRegistry(t *testing.T) {

	t.Parallel()

	checkAzureEnvVars(t, []string{})

	dirName := prepareTerraformDir(t)

	defer func() {
		err := os.RemoveAll(dirName)
		if err != nil {
			t.Fatalf("Could not remove directory %s", dirName)
		}
	}()

	terraformOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: dirName,
		Vars: map[string]interface{}{
			"create_registry": true,
			"location":        getDefaultAzureLocation(),
		},
		EnvVars: getTerraformEnvVars(),
	}

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	registryName := terraform.Output(t, terraformOptions, "container_registry_name")
	tenantId := terraform.Output(t, terraformOptions, "tenant_id")

	verifyAzureContainerRegistry(t, registryName+".azurecr.io", tenantId)

}

func verifyAzureContainerRegistry(t *testing.T, name string, tenantId string) {

	loginURI := "https://" + name
	imageName := "testimage"
	armAccessToken, err := getAzureADToken(ArmResource, "", "")

	if err != nil {
		t.Fatal("failed to get access token for Azure Resource Manager")
	}

	registryAccessToken, err := getRegistryAccessToken(armAccessToken.AccessToken, loginURI, name, tenantId, fmt.Sprintf("repository:%s:push,pull", imageName))

	if err != nil {
		t.Fatal("failed to get access token for Azure Container Registry")
	}

	blobClient := containerregistry.NewBlobClient(loginURI)
	blobClient.Authorizer = autorest.NewBearerAuthorizer(&adal.Token{
		AccessToken: registryAccessToken,
	})

	resp, err := blobClient.StartUpload(generateDefaultContext(AzureRmTimeout), imageName)

	assert.NoError(t, err)
	assert.Equal(t, 202, resp.StatusCode)
}
