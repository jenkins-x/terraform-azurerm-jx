package main

import (
	"context"
	"flag"
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/keyvault/2016-10-01/keyvault"
	"github.com/Azure/go-autorest/autorest"
	"github.com/Azure/go-autorest/autorest/adal"
	"github.com/Azure/go-autorest/autorest/azure"
	"log"
)

const (
	keyVaultResourceURI = "https://vault.azure.net"
)

func main() {

	vaultName := flag.String("vaultName", "", "Name the the Azure Key Vault")
	vaultKeyName := flag.String("vaultKeyName", "", "Name the the key to test for presence of")
	clientID := flag.String("clientId", "", "(optional) Client Id of service principal to authenticate to key vault with")
	clientSecret := flag.String("clientSecret", "", "(optional) Client secret of service principal)")
	tenantID := flag.String("tenantID", "", "(optional) Tenant Id in which service principal exists")

	flag.Parse()

	if *vaultName == "" || *vaultKeyName == "" {
		log.Fatal("Vault name and key vault must be specified")
	}

	token, err := getAccessToken(*tenantID, *clientID, *clientSecret, azure.PublicCloud)
	if err != nil {
		log.Fatalf("failed to get token: %v", err)
	}

	kvClient := keyvault.New()
	kvClient.Authorizer = autorest.NewBearerAuthorizer(token)

	keyBundle, err := kvClient.GetKey(context.Background(), fmt.Sprintf("https://%s.vault.azure.net/", *vaultName), *vaultKeyName, "")

	if err != nil {
		log.Fatal("Unable to retrieve keybundle")
	}

	if keyBundle.StatusCode != 200 {
		log.Fatal("Unauthorized to retrieve key")
	}
}

// getAccessToken retrieves Azure API access token.
func getAccessToken(tenantId string, clientID string, clientSecret string, environment azure.Environment) (*adal.ServicePrincipalToken, error) {

	// Try to retrieve token with service principal credentials.
	if len(clientID) > 0 && len(clientSecret) > 0 {
		oauthConfig, err := adal.NewOAuthConfig(environment.ActiveDirectoryEndpoint, tenantId)
		if err != nil {
			return nil, fmt.Errorf("failed to retrieve OAuth config: %v", err)
		}

		token, err := adal.NewServicePrincipalToken(*oauthConfig, clientID, clientSecret, keyVaultResourceURI)
		if err != nil {
			return nil, fmt.Errorf("failed to create service principal token: %v", err)
		}
		return token, nil
	}

	log.Print("Getting  v1 endpoint")
	msiEndpoint, err := adal.GetMSIVMEndpoint()
	if err != nil {
		return nil, fmt.Errorf("failed to get the managed service identity endpoint: %v", err)
	}

	log.Print("Getting service token  from msi endpoint")
	token, err := adal.NewServicePrincipalTokenFromMSI(msiEndpoint, keyVaultResourceURI)
	if err != nil {
		return nil, fmt.Errorf("failed to create the managed service identity token: %v", err)
	}
	return token, nil

}
