# Terraform for Azure AKS

## Prerequisites

-  Azure subscription: If you don't have an Azure subscription, create a free account before you begin.

- Configure Terraform: Follow the directions in the article, Terraform and configure access to Azure

- Azure service principal: Follow the directions in the section of the Create the service principal section in the article, Create an Azure service principal with Azure CLI. Take note of the values for the appId, displayName, password, and tenant.

## Getting started

Install the Azure [CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

> [Sign up for an Azure account](https://azure.microsoft.com/en-us/free/), if you don't own one already. You will receive $200 free credits.

1. Link your Azure CLI to your account with:

```bash
az login
```

2. List your accounts with:

```bash
az account list
```

3. Set your active subscription

 ```bash
 az account set --subscription="SUBSCRIPTION_ID"
 ```

4. Create the Service Principal

```bash
az ad sp create-for-rbac \
  --role="Contributor" \
  --scopes="/subscriptions/SUBSCRIPTION_ID"
```

You should have the following

```json
{
  "appId": "########-####-####-####-###########",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "########-####-####-####-###########",
  "tenant": "########-####-####-####-###########"
}
```

> _*Make sure you save the `appId`, `password` and `tenant`.*_

5. Export the following environment variables

```bash
export ARM_CLIENT_ID=<appId>
export ARM_SUBSCRIPTION_ID=<subscription id>
export ARM_TENANT_ID=<tenant>
export ARM_CLIENT_SECRET=<password>
```

6. Set up Azure storage to store Terraform state as described [here](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks#set-up-azure-storage-to-store-terraform-state)

7. Create the AKS cluster

```bash
terraform init -backend-config "storage_account_name=<YourAzureStorageAccountName>  -backend-config "container_name="container_name=tfstate" -backend-config="access_key=<YourStorageAccountAccessKey>"
```

aks usage example:

```terraform
module "aks" {
  source = "../../azure/aks"

  resource_group_name      = "aks-rg"
  resource_group_location  = "East US"
  cluster_name             = "akscluster"
  dns_prefix               = "aks"
  node_count               = "2"
  vm_size                  = "Standard_D2s_v3"
  ssh_public_key           = "~/.ssh/id_rsa.pub"
  service_principal_id     = "####-#####-#####"
  service_principal_secret = "#####-####-####"
  kubernetes_version       = "1.15.7"
  network_policy           = "azure"
  network_plugin           = "azure"
}
```