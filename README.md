# Jenkins X Azure Module

![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)

This repo contains a [Terraform](https://www.terraform.io/) Module for provisioning a Kubernetes cluster for [Jenkins X](https://jenkins-x.io/) on [Azure](https://azure.microsoft.com/en-us/).

<!-- TOC depthfrom:2 insertanchor:false -->

- [Jenkins X Azure Module](#jenkins-x-azure-module)
  - [What is a Terraform module](#what-is-a-terraform-module)
  - [How do you use this module](#how-do-you-use-this-module)
    - [Prerequisites](#prerequisites)
    - [Cluster provisioning](#cluster-provisioning)
      - [Inputs](#inputs)
      - [Outputs](#outputs)
    - [Production cluster considerations](#production-cluster-considerations)
    - [Configuring a Terraform backend](#configuring-a-terraform-backend)
    - [Examples](#examples)
  - [FAQ: Frequently Asked Questions](#faq-frequently-asked-questions)
  - [Development](#development)
    - [Releasing](#releasing)
  - [How can I contribute](#how-can-i-contribute)

<!-- /TOC -->

## What is a Terraform module

A Terraform module refers to a self-contained package of Terraform configurations that are managed as a group.
For more information about modules refer to the Terraform [documentation](https://www.terraform.io/docs/modules/index.html).

## How do you use this module

### Prerequisites

This Terraform module allows you to create an [AKS](https://azure.microsoft.com/en-us/services/kubernetes-service/) cluster for installation of Jenkins X.
You need the following binaries locally installed and configured on your _PATH_:

- `terraform` (~> 0.12.0)
- `kubectl` (>=1.10)
- `az` (>=2.5.1)

An Azure AD account or service principal with the following minimum privileges is required to execute Terraform under

- `Contributor + User Access Administator (Subscription)`
- `Cloud Application Administrator (Azure AD Role)`
- `Application.ReadWrite.All (Azure Active Directory Graph API permission)`

Currently the provisioning process uses [Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) which are currently in preview for AKS. These are required to enable RBAC within the cluster without manually creating service principals within Azure AD. [Pre-requisite steps](https://docs.microsoft.com/en-us/azure/aks/managed-aad) are required against the Azure subscription to enable this preview feature.

### Cluster provisioning

A default Jenkins X ready cluster can be provisioned by creating a _main.tf_ file in an empty directory with the following content:

```terraform
module "aks-jx" {
  source  = "jenkins-x/aks-jx/aks" 
}

```

The default configuration will create Azure resources under the Azure subscription you are currently logged in to via the `az` command line. This can be checked by running

```sh
az account show
```

 Once you have your initial configuration, you can apply it by running:

```sh
terraform init
terraform apply
```

This creates an AKS cluster with all possible configuration options defaulted.

:warning: **Note**: This example is for getting up and running quickly.
It is not intended for a production cluster.
Refer to [Production cluster considerations](#production-cluster-considerations) for things to consider when creating a production cluster.

The following sections provide a full list of configuration in- and output variables.

#### Inputs

| Name | Description | Type | Default | Required |
|:------:|-------------|:-----------:|:---------:|:-----:|
| apex\_domain | The apex domain in to which to create delegation records for the `domain_name` | `string` | `""` | no |
| apex\_domain\_resource\_group\_name | The resource group name in which the apex domain resides | `string` | `""` | no |
| apex\_domain\_integration\_enabled | Flag to integrate DNS zone in to an existing apex Azure DNS zon. Effectively creates subdomain delegation record in apex zone so DNS is immediately operable via Terraform. If set to true, then `apex_domain` and `apex_domain_resource_group_name` must also be configured | `bool` | `false` | no |
| cluster\_name | Variable to provide your desired name for the cluster. The script will create a random name if this is empty | `string` | `""` | no |
| cluster\_network\_model | Variable to define the network model for the cluster. Valid values are either `kubenet` or `azure` | `string` | `"kubenet"` | no |
| cluster\_resource\_group\_name | The name of the resource group in to which to provision AKS managed cluster. The script will create a random name if this is empty | `string` | `""` | no |
| cluster\_node\_resource\_group\_name | Resource group name in which to provision AKS cluster nodes. The script will create a random name if this is empty | `string` | `""` | no |
| cluster\_version | Kubernetes version to use for the AKS cluster. | `string` | `"1.18.8"` | no |
| container\_registry\_name | Name of container registry to provision. The script will create a random name if this is empty | `string` | `""` | no |
| create\_registry | Flag to indicate whether an Azure Container Registry should be provisioned | `bool` | `false` | no |
| dev\_env\_approvers | List of git users allowed to approve pull request for dev environment repository | `list(string)` | `[]` | no |
| domain\_name | The domain for external dns to create records in. The script will create a random name if this is empty | `string` | `""` | no |
| dns\_prefix | DNS prefix for the cluster. The script will create a random name if this is empty | `string` | `""` | no |
| dns\_resource\_group\_name | The name of the resource group in to which to provision dns resources. The script will create a random name if this is empty | `string` | `""` | no |
| enable\_backup | Whether or not Velero backups should be enabled | `bool` | `false` | no |
| enable\_log\_analytics | Flag to indicate whether to enable Log Analytics integration for cluster | `bool` | `false` | no |
| enable\_workload\_identity | Flag to indicate whether to enable workload identity in the form of Azure AD Pod Identity | `bool` | `false` | no |
| external\_dns\_enabled | Flag to enable external dns in `jx-requirerments.yml`. Requires `domain_name`, `apex_domain` and `apex_domain_resource_group_name` to be specified so the appropriate Azure DNS zone can be configured correctly.
| git\_owner\_requirement\_repos | The git id of the owner for the requirement repositories | `string` | `""` | no |
| jenkins\_x\_namespace | Kubernetes namespace to install Jenkins X in | `string` | `"jx"` | no |
| jx_git_url | URL for the Jenkins X cluster git repository | `string` | `""` | no |
| jx_bot_username | Bot username used to interact with the Jenkins X cluster git repository | `string` | `""` | no |
| jx_bot_token | Bot token used to interact with the Jenkins X cluster git repository | `string` | `""` | no |
| lets\_encrypt\_production | Flag to determine whether or not to use the Let's Encrypt production server. | `bool` | `true` | no |
| location | The Azure region in to which to provision the cluster | `string` | `"australiaeast"` | no |
| logging_retention_days | Number of days to retain logs in Log Analytics if enabled | `number` | `30` | no |
| network\_name | The name of the Virtual Network in Azure to be created. The script will create a random name if this is empty | `string` | `""` | no |
| network\_resource\_group\_name | The name of the resource group in to which to provision network resources. The script will create a random name if this is empty | `string` | `""` | no |
| node\_count | The number of worker nodes to use for the cluster | `number` | `1` | no |
| node\_size | The size of the worker node to use for the cluster | `string` | `"Standard_B2ms"` | no |
| registry\_resource\_group\_name | Name of resource group (to provision) in which to create registry. The script will create a random name if this is empty | `string` | `""` | no |
| secret\_management | Configures whether native secret storage is enabled and resource group to use. enable_native = true provisions Key vault store used by Kubernetes External Secrets. enable_native  = false uses Hashicorp vault (still backed by Azure Key Vault) |  `object` | `{ enable_native = false, resource_group_name = "" }` | no |
| subnet\_cidr | The CIDR of the provisioned  subnet within the `vnet_cidr` to to which worker nodes are placed | `string` | `"10.8.0.0/24"` | no |
| subnet\_name | The name of the subnet in Azure to be created. The script will create a random name if this is empty | `string` | `""` | no |
| tls | enable - Flag to enable TLS. email - Email used by Let's Encrypt | `object` | `{ enable = false, email = "" }` | no |
| velero\_namespace | Kubernetes namespace for Velero | `string` | `"velero"` | no |
| velero\_schedule | The Velero backup schedule in cron notation to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml)) | `string` | `"0 * * * *"` | no |
| velero\_ttl | The the lifetime of a Velero backup to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup)) | `string` | `"720h0m0s"` | no |
| version\_stream\_ref | The git ref for version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/ | `string` | `"master"` | no |
| version\_stream\_url | The URL for the version stream to use when booting Jenkins X. See https://jenkins-x.io/docs/concepts/version-stream/ | `string` | `"https://github.com/jenkins-x/jenkins-x-versions.git"` | no |
| vnet\_cidr | The CIDR of the provisioned Virtual Network in Azure in to which worker nodes are placed | `string` | `"10.8.0.0/16"` | no |
| webhook | Jenkins X webhook handler for git provider | `string` | `"lighthouse"` | no |

#### Outputs

| Name | Description |
|------|-------------|
| cluster\_fqdn | The FQDN of the created cluster |
| cluster\_name | The name of the created cluster |
| cluster\_node\_resource\_group | Resource group name that contains AKS VMs |
| cluster\_resource\_group | Resource group name that contains AKS managed cluster |
| connect | Command to run to connect to AKS cluster (downloads kube config) |
| container\_registry\_name | The name of the Azure Container Registry that was created |
| dns\_prefix | The FQDN of the created cluster |
| dns\_resource\_group | Resource group name in which DNS zone was created |
| domain\_name | The subdomain that houses `jx` hosts |
| dns\_name\_servers | Nameservers for the DNS zone created. Records should be provided to the parent domain administrators to create subdomain delegation records there |
| env\_vars | Executable command to set jx boot required environment variables |
| fully\_qualified\_domain\_name | The fully qualified domain name of the subdomain for 'jx' hosts |
| jx\_requirements | The jx-requirements rendered output |
| key\_vault\_client\_id | Client id for service principal authorised to connect to Azure Key Vault |
| key\_vault\_client\_secret | Client secret of service principal authorised to connect to Azure Key Vault |
| key\_vault\_name | Name of Azure Key Vault created |
| kube\_admin\_config\_raw | The raw kube config to auth to the AKS cluster |
| network\_name | The name of the virtual network |
| network\_resource\_group | Resource group name that contains virtual network |
| subnet\_name | The name of the subnet in which AKS is deployed |
| subscription\_id | Id of subscription in which resources were created |
| tenant\_id | The tenant id of the Azure Active Directory the cluster was created under |
| vault\_container\_name | Azure storage container name used for Hashicorp Vault backend |
| vault\_key\_name | Unseal key name used for Hasicorp vault (and stored in Azure Key Vault) |
| vault\_name | The name of the Key Vault backing Hashicorp Vault |
| vault\_resource\_group\_name | Resource group in which vault resources are created |
| vault\_storage\_account\_key | The storage account access key for Vault backend storage  |
| vault\_storage\_account\_name | The storage account name for Vault backend storage |
| vault\_workload\_identity\_selector | Azure AD Pod Identity selector to apply to pods to enable workload identity. Labels should be applied as `aadpodidbinding: <selector>` |
| velero\_client\_id | The client id of the service principal that Velero will use to authenticate to Azure storage |
| velero\_client\_secret | The client secret of the service principal that Velero will use to authenticate to Azure storage |
| velero\_container\_name | Container name created for Velero |
| velero\_namespace | The namespace that was created for Velero |
| velero\_storage\_account\_name | Storage account name created for Velero |
| velero\_storage\_resource\_group\_name | Resource group name that contains storage account for Velero |

#### JX Boot Environment secrets

The following environment variables must be present when running `jx boot` and can be sourced from terraform outputs. The terraform output `env_vars` contains an executable command to set these automatically.

| Environment Variable | Terraform Output |
|------|-------------|
| VAULT_AZURE_STORAGE_ACCESS_KEY | vault\_storage\_account\_key

### Production cluster considerations

The configuration, as seen in [Cluster provisioning](#cluster-provisioning), is not suited for creating and maintaining a production Jenkins X cluster.
The following is a list of considerations for a production use case.

- Specify the version attribute of the module, for example:

    ```terraform
    module "jx" {
      source  = "jenkins-x/aks-jx/aks"
      version = "1.0.0"
      # insert your configuration
    }
    ```

  Specifying the version ensures that you are using a fixed version and that version upgrades cannot occur unintended.

- Keep the Terraform configuration under version control by creating a dedicated repository for your cluster configuration or by adding it to an already existing infrastructure repository.

- Setup a Terraform backend to securely store and share the state of your cluster. For more information refer to [Configuring a Terraform backend](#configuring-a-terraform-backend).

### Configuring a Terraform backend

A "[backend](https://www.terraform.io/docs/backends/index.html)" in Terraform determines how state is loaded and how an operation such as _apply_ is executed.
By default, Terraform uses the _local_ backend, which keeps the state of the created resources on the local file system.
This is problematic since sensitive information will be stored on disk and it is not possible to share state across a team.
When working with AKS a good choice for your Terraform backend is the [Azure Storage backend](https://www.terraform.io/docs/backends/types/azurerm.html) which stores the Terraform state in Azure Storage Blob Storage.
The [examples](./examples) directory of this repository contains configuration examples for using the Azure Storage backed.

To use the Azure Storage backend, you will need to create the Storage Account and Container upfront.

### Examples

You can find examples for different configurations in the [examples folder](./examples).

Each example generates a valid _jx-requirements.yml_ file that can be used to boot a Jenkins X cluster.

## FAQ: Frequently Asked Questions

None currently. Check back later!

## Development

### Releasing

At the moment, there is no release pipeline defined.
A Terraform release does not require building an artifact; only a tag needs to be created and pushed.
To make this task easier and there is a helper script `release.sh` which simplifies this process and creates the changelog as well:

```sh
./scripts/release.sh
```

This can be executed on demand whenever a release is required.
For the script to work, the environment variable _$GH_TOKEN_ must be exported and reference a valid GitHub API token.

## How can I contribute

Contributions are very welcome! Check out the [Contribution Guidelines](./CONTRIBUTING.md) for instructions.
