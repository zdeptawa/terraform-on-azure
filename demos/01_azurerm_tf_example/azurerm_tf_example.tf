# This is an example of a basic Terraform configuration file that sets up a new demo resource group,
# and creates a new demo network with a public and private subnet.

# IMPORTANT: Make sure subscription_id, client_id, client_secret, and tenant_id are configured!

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "demo01_resource_group" {
  name     = "demo01_resource_group"
  location = "westus2"

  tags = { environment = "demo", build = "demo01" }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "demo01_network" {
  name                = "demo01_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo01_resource_group.location
  resource_group_name = azurerm_resource_group.demo01_resource_group.name

  subnet {
    name           = "demo01_public_subnet"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "demo01_private_subnet"
    address_prefix = "10.0.2.0/24"
  }

  tags = { environment = "demo", build = "demo01" }
}
