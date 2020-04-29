# This is an example of a basic Terraform configuration file that sets up a new demo resource group,
# and creates a new demo network with a linux server in that network.

# IMPORTANT: Make sure subscription_id, client_id, client_secret, and tenant_id are configured!

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "demo06_resource_group" {
  name     = "demo06_resource_group"
  location = "westus2"

  tags = { environment = "demo", build = "demo06" }
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.0.0"
  resource_group_name = azurerm_resource_group.demo06_resource_group.name
  subnet_prefixes     = ["10.0.1.0/24"]

  tags = { environment = "demo", build = "demo06" }
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.demo06_resource_group.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["demo06-vm-ips"] # same as domain_name_label, name must be unique per DC region, only letters and hyphens,
  #                                        # must start with letter and end with letter or number.
  vnet_subnet_id      = module.network.vnet_subnets[0]

  tags = { environment = "demo", build = "demo06" }
}

output "linux_vm_public_name" {
  value = module.linuxservers.public_ip_dns_name
}