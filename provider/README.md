# Azure Provider

## Summary

This module will configure a provider and install required packages mentioned below, needed by terraform to deploy Azure infrastructure resources.

### Azure Resource Manager (Version 1.40.0 or higher)

Azure Resource Manager enables you to repeatedly deploy your app and have confidence your resources are deployed in a consistent state.
#### Usage

Below code snippet example will use Azure Resource Manager to deploy a resource of type resource group. Additional details regarding Azure Resource Manager on Terraform can be found [here](https://www.terraform.io/docs/providers/azurerm/index.html)

```
resource "azurerm_resource_group" "example" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}
```

### Terraform (Version 0.12.6 or higher)

Terraform enables you to safely and predictably create, change, and improve infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned. 

#### Usage

Below are the commands used for deploying resources on Azure using terraform templates. List of all terraform commands can be found [here](https://www.terraform.io/docs/commands/index.html)

```
terraform init  <folder-name>
terraform apply <folder-name>
```

### Azure Active Directory (Version 0.7.0 or higher)

Azure Active Directory provides reliability and scalability one needs with identity services that work with on-premises, cloud, or hybrid environment. 

#### Usage

Below code snippet example uses Azure Active Directory to Read service principal object to create a role assignment. Additional details regarding Azure Active Directory on Terraform can be found [here](https://www.terraform.io/docs/providers/azuread/index.html)

```
data "azuread_service_principal" "example" {
    application_id = "${var.service_principal_id}"
}
```

### Null Provider (Version 2.1.2 or higher)

Null Provider provided by Terraform is needed in situations where one wants to execute external scripts to get configuration details of resources, not provided by terraform outputs, that are going to be created using terraform. 

#### Usage

Below code snippet example uses Null Provider to update trigger based on the trigger condition and executes the shell script locally. Additional details regarding Null Provider on Terraform can be found [here](https://www.terraform.io/docs/providers/null/index.html)

```
resource "null_resource" "example" {
    triggers {
        trigger = trigger-condition
    }
    provisioner "local-exec" {
        command = "execute shell script"
    }
}
```