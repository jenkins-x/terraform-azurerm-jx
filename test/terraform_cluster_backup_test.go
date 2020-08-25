package test

import (
	"bytes"
	"context"
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/storage/mgmt/2019-06-01/storage"
	"github.com/Azure/azure-storage-blob-go/azblob"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"net/url"
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
		},
		EnvVars: getTerraformEnvVars(),
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

	authorizer, err := azure.NewAuthorizer()
	if err != nil {
		t.Fatal("Unable to create Azure authorizer from environment")
	}

	ctx := context.Background()
	blobClient := storage.NewBlobContainersClientWithBaseURI(storage.DefaultBaseURI, subscriptionId)
	blobClient.Authorizer = *authorizer

	_, err = blobClient.Get(ctx, storageResourceGroupName, storageAccountName, containerName)

	if assert.NoError(t, err) {

		storageAccessToken, err := getAzureADToken(AzureStorageResourceID, veleroClientId, veleroClientSecret)

		if err != nil {
			t.Fatal("failed to get access token for Azure Resource Manager")
		}

		credential := azblob.NewTokenCredential(storageAccessToken.AccessToken, nil)
		u, err := url.Parse(fmt.Sprintf("https://%s.blob.core.windows.net/%s", storageAccountName, containerName))
		if assert.NoError(t, err) {
			containerURL := azblob.NewContainerURL(*u, azblob.NewPipeline(credential, azblob.PipelineOptions{}))
			blobURL := containerURL.NewBlockBlobURL("test")
			resp, err := azblob.UploadStreamToBlockBlob(ctx, bytes.NewReader([]byte("testData")), blobURL, azblob.UploadStreamToBlockBlobOptions{})

			// Assert no error return from upload blob request
			if assert.NoError(t, err) {
				// Assert 201 - Created response message back from upload blob request
				assert.Equal(t, 201, resp.Response().StatusCode)
			}

		}
	}

}
