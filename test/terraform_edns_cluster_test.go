package test

import (
	"github.com/Azure/azure-sdk-for-go/services/dns/mgmt/2018-05-01/dns"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"os"
	"path"
	"testing"
)

func TestTerraformEDnsWithApexDomainCluster(t *testing.T) {

	t.Parallel()

	checkAzureEnvVars(t, []string{
		ApexDomain,
		ApexDomainResourceGroup,
	})

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
			"external_dns_enabled":            true,
			"apex_domain":                     os.Getenv(ApexDomain),
			"apex_domain_resource_group_name": os.Getenv(ApexDomainResourceGroup),
			"apex_domain_integration_enabled": true,
			"location":                        getDefaultAzureLocation(),
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
	dnsResourceGroupName := terraform.Output(t, terraformOptions, "dns_resource_group")
	domainName := terraform.Output(t, terraformOptions, "fully_qualified_domain_name")

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

		options := k8s.NewKubectlOptions("", kubeConfigPath, "default")

		// Assert that jx namespace exists within cluster
		_ = k8s.GetNamespace(t, options, "jx")

		authorizer, err := azure.NewAuthorizer()
		if err != nil {
			t.Fatal("Unable to create Azure authorizer from environment")
		}

		dnsClient := dns.NewZonesClient(subscriptionId)
		dnsClient.Authorizer = *authorizer

		_, err = dnsClient.Get(generateDefaultContext(AzureRmTimeout), dnsResourceGroupName, domainName)

		// Assert we get no error back from requesting the Azure DNS Zone
		assert.NoError(t, err)
	}

}
