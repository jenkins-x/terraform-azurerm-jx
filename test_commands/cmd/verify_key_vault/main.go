package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/keyvault/2016-10-01/keyvault"
	"github.com/Azure/go-autorest/autorest/azure/auth"
)

const (
	keyVaultResourceURI    = "https://vault.azure.net"
	defaultAzureAPITimeout = time.Duration(120) * time.Second
)

func main() {

	vaultName := flag.String("vaultName", "", "Name the the Azure Key Vault")
	vaultKeyName := flag.String("vaultKeyName", "", "Name the the key to test for presence of")

	flag.Parse()

	if *vaultName == "" || *vaultKeyName == "" {
		log.Fatal("Vault name and key vault must be specified")
	}

	err := os.Setenv(auth.Resource, keyVaultResourceURI)
	if err != nil {
		log.Fatal("Unable to set resource Id on environment " + err.Error())
	}

	authorizer, err := auth.NewAuthorizerFromEnvironment()
	if err != nil {
		log.Fatal("Unable to configure autorest authorizer from environment " + err.Error())
	}

	kvClient := keyvault.New()
	kvClient.Authorizer = authorizer

	log.Print("Getting Key Bundle")
	ctx, _ := context.WithTimeout(context.Background(), defaultAzureAPITimeout)
	keyBundle, err := kvClient.GetKey(ctx, fmt.Sprintf("https://%s.vault.azure.net/", *vaultName), *vaultKeyName, "")

	if err != nil {
		log.Fatal("Unable to retrieve key bundle " + err.Error())
	}

	if keyBundle.StatusCode != 200 {
		log.Fatal("Unauthorized to retrieve key")
	}
	log.Print("Retrieved key bundle successfully")
}
