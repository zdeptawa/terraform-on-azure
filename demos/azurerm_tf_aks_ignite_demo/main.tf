# Setting the provider
provider "azurerm" {
  version = "~>1.5"
}

# Configuring the backend
terraform {
  backend "${var.terraform_backend}" {}
}
