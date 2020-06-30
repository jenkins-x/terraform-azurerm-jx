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
|------|-------------|------|---------|:--------:|
| cluster\_name | Variable to provide your desired name for the cluster. The script will create a random name if this is empty | `string` | `""` | no |
| cluster\_version | Kubernetes version to use for the EKS cluster. | `string` | `"1.15"` | no |
| node_count | The number of worker nodes to use for the cluster | `number` | `1` | no |
| node_size | The size of the worker node to use for the cluster | `string` | `"Standard_B2ms"` | no |
| dns_prefix | DNS prefix for the cluster. The script will create a random name if this is empty | `string` | `""` | no |
| location | The Azure region in to which to provision the cluster | `string` | `"australiaeast"` | no |
| network_resource_group | The name of the resource group in to which to provision network resources. The script will create a random name if this is empty | `string` | `""` | no |
| cluster_resource_group | The name of the resource group in to which to provision cluster resources. The script will create a random name if this is empty | `string` | `""` | no |
| vnet_cidr | The CIDR of the provisioned Virtual Network in Azure in to which worker nodes are placed | `string` | `"10.8.0.0/16"` | no |
| subnet_cidr | The CIDR of the provisioned  subnet within the `vnet_cidr` to to which worker nodes are placed | `string` | `"10.8.0.0/24"` | no |
| network_name | The name of the Virtual Network in Azure to be created. The script will create a random name if this is empty | `string` | `""` | no |
| subnet_name | The name of the subnet in Azure to be created. The script will create a random name if this is empty | `string` | `""` | no |
| dns_resource_group | The name of the resource group in to which to provision dns resources. The script will create a random name if this is empty | `string` | `""` | no |
| domain_name | The domain for external dns to create records in. The script will create a random name if this is empty | `string` | `""` | no |
| dns_enabled | Flag which sets whether a DNS zone is provisioned or not | `bool` | `true` | no |
| apex_domain | The apex domain in to which to create delegation records for the `domain_name` | `string` | `""` | no |
| apex_domain_resource_group_name | The resource group name in which the apex domain resides | `string` | `""` | no |

#### Outputs

| Name | Description |
|------|-------------|
| cluster\_name | The name of the created cluster |
| cluster_fqdn | The FQDN of the created cluster |

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

At the moment, there is no release pipeline defined in [jenkins-x.yml](./jenkins-x.yml).
A Terraform release does not require building an artifact; only a tag needs to be created and pushed.
To make this task easier and there is a helper script `release.sh` which simplifies this process and creates the changelog as well:

```sh
./scripts/release.sh
```

This can be executed on demand whenever a release is required.
For the script to work, the environment variable _$GH_TOKEN_ must be exported and reference a valid GitHub API token.

## How can I contribute

Contributions are very welcome! Check out the [Contribution Guidelines](./CONTRIBUTING.md) for instructions.
