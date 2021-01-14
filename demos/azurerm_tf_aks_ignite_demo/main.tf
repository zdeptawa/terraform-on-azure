# Setting the provider
provider "azurerm" {
  features {}
}

# Configuring the backend
# Use "azurerm" if you'd like to use a Storage Container 
# to store the Terraform state remotely
terraform {
  backend "local" {}
}