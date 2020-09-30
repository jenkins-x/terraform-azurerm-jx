package test

import (
	"bytes"
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/storage/mgmt/2019-06-01/storage"
	"github.com/Azure/azure-storage-blob-go/azblob"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
	"net/url"
	"testing"
)

func verifyStorageContainer(t *testing.T, subscriptionId string, storageResourceGroupName string, storageAccountName string, containerName string, blobCredential azblob.Credential) {

	authorizer, err := azure.NewAuthorizer()
	if err != nil {
		t.Fatal("Unable to create Azure authorizer from environment")
	}

	ctx := generateDefaultContext(AzureRmTimeout)
	blobClient := storage.NewBlobContainersClientWithBaseURI(storage.DefaultBaseURI, subscriptionId)
	blobClient.Authorizer = *authorizer

	_, err = blobClient.Get(ctx, storageResourceGroupName, storageAccountName, containerName)

	// Verify we can get a client to BlobContainer without error
	if assert.NoError(t, err) {

		u, err := url.Parse(fmt.Sprintf("https://%s.blob.core.windows.net/%s", storageAccountName, containerName))
		if assert.NoError(t, err) {
			containerURL := azblob.NewContainerURL(*u, azblob.NewPipeline(blobCredential, azblob.PipelineOptions{}))
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
