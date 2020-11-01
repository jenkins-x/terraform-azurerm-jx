package test

import (
	"io/ioutil"
	"os"
	"path"
	"testing"

	"github.com/Azure/azure-storage-blob-go/azblob"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformWorkloadIdentity(t *testing.T) {

	t.Parallel()

	checkAzureEnvVars(t, []string{verifyKeyVaultDockerImage})

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
			"location":                 getDefaultAzureLocation(),
			"enable_workload_identity": true,
			"is_jx2":                   false,
		},
		EnvVars: getTerraformEnvVars(),
	}

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	resourceGroupName := terraform.Output(t, terraformOptions, "cluster_resource_group")
	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	subscriptionId := terraform.Output(t, terraformOptions, "subscription_id")
	kubeConfigRaw := terraform.Output(t, terraformOptions, "kube_admin_config_raw")
	vaultStorageAccountName := terraform.Output(t, terraformOptions, "vault_storage_account_name")
	vaultStorageAccountKey := terraform.Output(t, terraformOptions, "vault_storage_account_key")
	vaultStorageResourceGroupName := terraform.Output(t, terraformOptions, "vault_resource_group_name")
	vaultName := terraform.Output(t, terraformOptions, "key_vault_name")
	vaultContainerName := terraform.Output(t, terraformOptions, "vault_container_name")
	vaultKeyName := terraform.Output(t, terraformOptions, "vault_key_name")
	workloadIdentitySelector := terraform.Output(t, terraformOptions, "vault_workload_identity_selector")

	kubeConfigPath := path.Join(dirName, ".kubeconfig")
	err := ioutil.WriteFile(kubeConfigPath, []byte(kubeConfigRaw), 500)

	if err != nil {
		t.Fatal("Unable to write kube config to disk")
	}

	// Test we can get a handle on managed cluster client without error
	managedCluster, err := azure.GetManagedClusterE(t, resourceGroupName, clusterName, subscriptionId)

	if assert.NoError(t, err) {
		// Assert provisioning status is Succeeded against the AKS cluster
		assert.Equal(t, "Succeeded", *managedCluster.ProvisioningState)

		credential, err := azblob.NewSharedKeyCredential(vaultStorageAccountName, vaultStorageAccountKey)

		if err != nil {
			t.Fatal("Unable to configure new shared key credential for Azure Storage")
		}

		// Check Vault storage
		verifyStorageContainer(t, subscriptionId,
			vaultStorageResourceGroupName,
			vaultStorageAccountName,
			vaultContainerName,
			credential)

		// Check Vault Key Vault Access from within cluster by running Kubernetes job
		clientSet, err := NewK8s(kubeConfigPath)

		if err != nil {
			t.Fatalf("Unable to build k8s clientSet")
		}

		var containerArgs = []string{"-vaultName", vaultName, "-vaultKeyName", vaultKeyName}
		var labels = map[string]string{
			"aadpodidbinding": workloadIdentitySelector,
		}
		exitCode, logs, err := ExecuteJob("verify-key-vault-job", os.Getenv(verifyKeyVaultDockerImage), containerArgs, labels, clientSet)

		assert.NoError(t, err)

		if !assert.Equal(t, int32(0), exitCode) {
			t.Logf("Non zero exit code returned from pod - pod logs are: %s", logs)
		}

	}
}
