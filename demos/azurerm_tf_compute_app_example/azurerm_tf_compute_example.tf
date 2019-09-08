# This is an example of a basic Terraform configuration file that sets up a new demo resource group,
# and creates a new demo network with a web server in a public subnet behind a load balancer.

# IMPORTANT: Make sure subscription_id, client_id, client_secret, and tenant_id are configured!

# Configure the Azure Provider
provider "azurerm" {}

# Create a resource group
resource "azurerm_resource_group" "demo_resource_group" {
  name     = "demo_lin_resource_group"
  location = "westus2"

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}

# Create a virtual network within the resource group
module "network" "demo_network" {
  source              = "Azure/network/azurerm"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_names        = ["demo_lin_public_subnet", "demo_lin_private_subnet"]
  vnet_name           = "demo_lin_network"

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}

# Create a subnet within the network
resource "azurerm_subnet" "demo_public_subnet" {
  name                      = "demo_lin_public_subnet"
  address_prefix            = "10.0.1.0/24"
  resource_group_name       = "${azurerm_resource_group.demo_resource_group.name}"
  virtual_network_name      = "demo_network"
  network_security_group_id = "${azurerm_network_security_group.demo_public_security_group.id}"
}

# Create a security group
resource "azurerm_network_security_group" "demo_public_security_group" {
  depends_on          = ["module.network"]
  name                = "demo_lin_public_security_group"
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"

  security_rule {
    name                       = "demo_allow_web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}

# Create a network interface for the server
resource "azurerm_network_interface" "demo_network_interface" {
  name                      = "demo_lin_network_interface"
  location                  = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name       = "${azurerm_resource_group.demo_resource_group.name}"
  network_security_group_id = "${azurerm_network_security_group.demo_public_security_group.id}"

  ip_configuration {
    name                                    = "demo_lin_ip_configuration"
    subnet_id                               = "${azurerm_subnet.demo_public_subnet.id}"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${module.loadbalancer.azurerm_lb_backend_address_pool_id}"]
  }

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}

# Create a managed disk for the server
resource "azurerm_managed_disk" "demo_managed_disk" {
  name                 = "demo_lin_managed_disk"
  location             = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name  = "${azurerm_resource_group.demo_resource_group.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}

# Create a web servrer
resource "azurerm_virtual_machine" "demo_web01" {
  name                  = "demo_lin_web01"
  location              = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name   = "${azurerm_resource_group.demo_resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.demo_network_interface.id}"]
  vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "demo_lin_storage_os_disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.demo_managed_disk.name}"
    managed_disk_id = "${azurerm_managed_disk.demo_managed_disk.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.demo_managed_disk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "demolinweb01"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}

# Run some commands on the web server for post build setup
resource "azurerm_virtual_machine_extension" "demo_web_build" {
  name                 = "demo_lin_web_build"
  location             = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name  = "${azurerm_resource_group.demo_resource_group.name}"
  virtual_machine_name = "${azurerm_virtual_machine.demo_web01.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update -y && sudo apt-get install nginx -y"
    }
SETTINGS

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}

# Create a loadbalancer
module "loadbalancer" "demo_load_balancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  prefix              = "demolin"

  lb_port = {
    http = ["80", "Tcp", "80"]
  }

  frontend_name = "demo-lin-public-vip"

  tags {
    environment = "demo-app-lin"
    build       = "devops-demo-app"
  }
}
