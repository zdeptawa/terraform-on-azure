# This is an example of a basic Terraform configuration file that sets up a new demo resource group,
# and creates a new demo network with a web server in a public subnet behind a load balancer.

# IMPORTANT: Make sure subscription_id, client_id, client_secret, and tenant_id are configured!

# Configure the Azure Provider
provider "azurerm" {
  version = "~> 1.33"
}

# Create a resource group
resource "azurerm_resource_group" "demo_resource_group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a virtual network within the resource group
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  address_space       = "${var.address_space}"
  subnet_prefixes     = "${var.subnet_prefixes}"
  subnet_names        = "${var.subnet_names}"
  vnet_name           = "${var.vnet_name}"

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a subnet within the network
resource "azurerm_subnet" "demo_public_subnet" {
  depends_on            = ["module.network"]
  name                  = "${var.public_subnet_name}"
  address_prefix        = "${var.public_subnet_prefix}"
  resource_group_name   = "${azurerm_resource_group.demo_resource_group.name}"
  virtual_network_name  = "${var.vnet_name}"
}

resource "azurerm_subnet_network_security_group_association" "demo_security_group_association" {
  subnet_id = "${azurerm_subnet.demo_public_subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.demo_public_security_group.id}"
}

# Create a security group
resource "azurerm_network_security_group" "demo_public_security_group" {
  depends_on          = ["module.network"]
  name                = "${var.public_security_group_name}"
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

  security_rule {
    name                       = "demo_allow_rdp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a public IP for the server
resource "azurerm_public_ip" "demo_web_public_ip" {
  name                = "demo_web_public_ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"
  allocation_method   = "Static"

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a network interface for the server
resource "azurerm_network_interface" "demo_network_interface" {
  name                      = "${var.network_interface_name}"
  location                  = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name       = "${azurerm_resource_group.demo_resource_group.name}"
  network_security_group_id = "${azurerm_network_security_group.demo_public_security_group.id}"

  ip_configuration {
    name                                    = "${var.ip_configuration_name}"
    subnet_id                               = "${azurerm_subnet.demo_public_subnet.id}"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${module.loadbalancer.azurerm_lb_backend_address_pool_id}"]
    public_ip_address_id                    = "${azurerm_public_ip.demo_web_public_ip.id}"
  }

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a managed disk for the server
resource "azurerm_managed_disk" "demo_managed_disk" {
  name                 = "${var.web_managed_disk_name}"
  location             = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name  = "${azurerm_resource_group.demo_resource_group.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a web servrer
resource "azurerm_virtual_machine" "demo_web01" {
  name                  = "${var.web_server_name}"
  location              = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name   = "${azurerm_resource_group.demo_resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.demo_network_interface.id}"]
  vm_size               = "${var.web_vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "demo_win_storage_os_disk1"
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
    computer_name  = "demowinweb01"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_windows_config { }

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a loadbalancer
module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  prefix              = "${var.lb_prefix}"

  remote_port = {
    rdp = ["Tcp", "3389"]
  }

  lb_port = {
    http = ["80", "Tcp", "80"]
  }

  frontend_name = "${var.lb_frontend_name}"

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}
