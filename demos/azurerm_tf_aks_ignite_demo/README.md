# terraform-on-azure - Microsoft Ignite K8s Demo
# Deploying an Azure Kubernetes Service (AKS) Cluster and Azure Function App with Terraform
Very basic sample Terraform configuration utilizing the AzureRM Terraform Provider to deploy an
Azure Kubernetes Service (AKS) Cluster. Also deploys an Azure Function App and sample function.

# Prerequisites
Before you can use this code, you'll need to gather and configure your Azure Authentication info(`client_id`, `client_secret`, `tenant_id`, `subscription_id`). While you can use your own personal authentication information, it is suggested that you use an Azure Service Principal instead. [How to create a Service Principal for use with Terraform can be found here](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html).

You will also need Terraform and Git installed on your system. If you don't yet have Terraform installed, [this guide will help you get it set up](https://www.terraform.io/intro/getting-started/install.html). If you still need to install Git, [you can download it here](https://git-scm.com/downloads).

This demo code also requires an Azure Storage 

# Usage
To use/test this code, do the following:

1. Clone this repository.
2. Change directory to this demo folder.
3. Configure your Azure Authentication information (client_id, client_secret, tenant_id, subscription_id) via Terraform variables or - the preferred method - environment variables.
4. Run `terraform init` to initialize the Terraform environment in this directory and pull down required providers and modules.
5. Run `terraform plan` to plan the changes and build the dependency graphs required. This will also allow you to see what changes will occur before applying.
6. **ONLY IF ALL LOOKS WELL ON THE PLAN**, run `terraform apply` to apply your changes.

# Sample Script For Exporting Azure Authentication Credentials as Environment Variables
Here is a sample script for Linux/MacOS that you can source to export your authentication credentials as environment variables that will be seen and used by Terraform. Be sure to not store this file in your repository as it contains sensitive authentication information for your account!

```
#!/bin/sh

export ARM_CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_CLIENT_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_ENVIRONMENT="public"

export TF_VAR_client_id=${ARM_CLIENT_ID}
export TF_VAR_client_secret=${ARM_CLIENT_SECRET}
export TF_VAR_subscription_id=${ARM_SUBSCRIPTION_ID}
export TF_VAR_tenant_id=${ARM_TENANT_ID}
```

# More Information
Docs on Terraform.io -> [https://www.terraform.io/docs/providers/azurerm/](https://www.terraform.io/docs/providers/azurerm/)

Docs on Microsoft -> [https://aka.ms/tfhub](https://aka.ms/tfhub)