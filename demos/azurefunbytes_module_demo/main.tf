# This is an example of a basic Terraform configuration file that sets up a new demo resource group,
# a new demo network, and a new demo linux server with nginx running and accessible via port 80.

# IMPORTANT: Make sure subscription_id, client_id, client_secret, and tenant_id are configured!

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "azfunbytes_resource_group" {
  name     = "azfunbytes_demo_2"
  location = "West US 2"

  tags     = { environment = "demo", build = "azfunbytes2" }
}

# Create a network
module "azfunbytes_network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.azfunbytes_resource_group.name
  subnet_prefixes     = ["10.0.2.0/24"]
  subnet_names        = ["azfunbytes_internal_subnet"]
  tags                = { environment = "demo", build = "azfunbytes2" }

  depends_on = [azurerm_resource_group.azfunbytes_resource_group]
}

# Create a virtual machine
module "azfunbytes_linux_vm" {
  source                = "Azure/compute/azurerm"
  resource_group_name   = azurerm_resource_group.azfunbytes_resource_group.name
  vm_hostname           = "azfunbytes-web"
  vm_size               = "Standard_F2"
  vm_os_simple          = "UbuntuServer"
  admin_username        = "adminuser"
  ssh_key               = "~/.ssh/id_rsa.pub"
  storage_account_type  = "Standard_LRS"
  remote_port           = "80"
  vnet_subnet_id        = module.azfunbytes_network.vnet_subnets[0]
  tags                  = { environment = "demo", build = "azfunbytes2" }

  depends_on = [azurerm_resource_group.azfunbytes_resource_group]
}

# Run a sample script to update the server and install nginx after it's done building
resource "azurerm_virtual_machine_extension" "azfunbytes_vm_web_build" {
  name                 = "azfunbytes_vm_web_build"
  virtual_machine_id   = module.azfunbytes_linux_vm.vm_ids[0]
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update -y && sudo apt-get install nginx -y"
    }
SETTINGS

  tags = { environment = "demo", build = "azfunbytes" }

  depends_on = [module.azfunbytes_linux_vm]
}

output "linux_vm_public_name" {
  value = module.azfunbytes_linux_vm.public_ip_address
}