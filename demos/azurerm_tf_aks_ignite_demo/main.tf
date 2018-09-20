# Setting the provider
provider "azurerm" {
  version = "~>1.5"
}

# Configuring the backend
# Use "azurerm" if you'd like to use a Terraform Storage Container as the backend
terraform {
  backend "local" {}
}
