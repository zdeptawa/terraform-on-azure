# This is an example of a basic Terraform configuration file that sets up a new demo resource group,
# and creates a new demo network with three subnets.

# What credentials are needed to configure the AzureRM provider?
## subscription_id
# The subscription ID to use. It can also be sourced from the ARM_SUBSCRIPTION_ID environment variable.

## client_id
# The client ID to use. It can also be sourced from the ARM_CLIENT_ID environment variable.

## client_secret
# The client secret to use. It can also be sourced from the ARM_CLIENT_SECRET environment variable.

## tenant_id
# The tenant ID to use. It can also be sourced from the ARM_TENANT_ID environment variable.

# Configure the Azure Provider
provider "azurerm" {}

# Create a resource group
resource "azurerm_resource_group" "demo_resource_group" {
  name     = "demo_resource_group"
  location = "West US"

  tags {
    environment = "demo"
  }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "demo_network" {
  name                = "demo_network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
  }

  tags {
    environment = "demo"
  }
}
