module github.com/jenkins-x/terraform-azurerm-jx

go 1.13

require (
	github.com/Azure/azure-sdk-for-go v45.1.0+incompatible
	github.com/Azure/azure-storage-blob-go v0.10.0
	github.com/Azure/go-autorest/autorest v0.11.4
	github.com/Azure/go-autorest/autorest/adal v0.9.2
	github.com/Azure/go-autorest/autorest/azure/auth v0.4.2
	github.com/google/uuid v1.1.1
	github.com/gruntwork-io/terratest v0.28.13
	github.com/otiai10/copy v1.2.0
	github.com/stretchr/testify v1.6.1
	golang.org/x/crypto v0.0.0-20200728195943-123391ffb6de // indirect
	k8s.io/api v0.18.3
	k8s.io/apimachinery v0.18.3
	k8s.io/client-go v0.18.3
)
