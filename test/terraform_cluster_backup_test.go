package test

import (
	"github.com/Azure/azure-storage-blob-go/azblob"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"io/ioutil"
	"os"
	"path"

	"testing"
)

func TestTerraformWithBackupEnabledTest(t *testing.T) {

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
			"enable_backup": true,
			"location":      getDefaultAzureLocation(),
		},
		EnvVars:    getTerraformEnvVars(),
		MaxRetries: 5,
	}

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	veleroNamespace := terraform.Output(t, terraformOptions, "velero_namespace")
	storageResourceGroupName := terraform.Output(t, terraformOptions, "velero_storage_resource_group_name")
	storageAccountName := terraform.Output(t, terraformOptions, "velero_storage_account_name")
	containerName := terraform.Output(t, terraformOptions, "velero_container_name")
	kubeConfigRaw := terraform.Output(t, terraformOptions, "kube_admin_config_raw")
	subscriptionId := terraform.Output(t, terraformOptions, "subscription_id")
	veleroClientId := terraform.Output(t, terraformOptions, "velero_client_id")
	veleroClientSecret := terraform.Output(t, terraformOptions, "velero_client_secret")

	kubeConfigPath := path.Join(dirName, ".kubeconfig")
	err := ioutil.WriteFile(kubeConfigPath, []byte(kubeConfigRaw), 500)

	if err != nil {
		t.Error("Unable to write kube config to disk")
	}

	options := k8s.NewKubectlOptions("", kubeConfigPath, "default")

	// Assert that Velero namespace exists within cluster
	_ = k8s.GetNamespace(t, options, veleroNamespace)

	verifyStorageContainer(t, subscriptionId, storageResourceGroupName, storageAccountName, containerName, getBlobTokenCredential(t, veleroClientId, veleroClientSecret))

}

func getBlobTokenCredential(t *testing.T, clientID string, clientSecret string) azblob.Credential {

	storageAccessToken, err := getAzureADToken(AzureStorageResourceID, clientID, clientSecret)
	if err != nil {
		t.Fatal("failed to get access token for Azure Resource Manager")
	}

	return azblob.NewTokenCredential(storageAccessToken.AccessToken, nil)
}
