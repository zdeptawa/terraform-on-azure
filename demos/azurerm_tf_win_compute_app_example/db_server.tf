# Create a private subnet within the network
resource "azurerm_subnet" "demo_private_subnet" {
  depends_on            = ["module.network"]
  name                  = "${var.private_subnet_name}"
  address_prefix        = "${var.private_subnet_prefix}"
  resource_group_name   = "${azurerm_resource_group.demo_resource_group.name}"
  virtual_network_name  = "${var.vnet_name}"
}

resource "azurerm_subnet_network_security_group_association" "demo_private_security_group_association" {
  subnet_id = "${azurerm_subnet.demo_private_subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.demo_private_security_group.id}"
}

# Create a security group
resource "azurerm_network_security_group" "demo_private_security_group" {
  depends_on          = ["module.network"]
  name                = "${var.private_security_group_name}"
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"

  security_rule {
    name                       = "demo_allow_db"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "${var.public_subnet_prefix}"
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
resource "azurerm_public_ip" "demo_db_public_ip" {
  name                = "demo_db_public_ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"
  allocation_method   = "Static"

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a network interface for the server
resource "azurerm_network_interface" "demo_network_interface_db" {
  name                      = "${var.network_interface_db_name}"
  location                  = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name       = "${azurerm_resource_group.demo_resource_group.name}"
  network_security_group_id = "${azurerm_network_security_group.demo_private_security_group.id}"

  ip_configuration {
    name                                    = "${var.ip_configuration_db_name}"
    subnet_id                               = "${azurerm_subnet.demo_private_subnet.id}"
    private_ip_address_allocation           = "dynamic"
    public_ip_address_id                    = "${azurerm_public_ip.demo_db_public_ip.id}"
  }

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

# Create a managed disk for the server
resource "azurerm_managed_disk" "demo_db_managed_disk" {
  name                 = "${var.db_managed_disk_name}"
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
resource "azurerm_virtual_machine" "demo_db01" {
  name                  = "${var.db_server_name}"
  location              = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name   = "${azurerm_resource_group.demo_resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.demo_network_interface_db.id}"]
  vm_size               = "${var.db_vm_size}"

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
    name              = "demo_win_storage_os_db_disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.demo_db_managed_disk.name}"
    managed_disk_id = "${azurerm_managed_disk.demo_db_managed_disk.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.demo_db_managed_disk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "demowindb01"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_windows_config { }

  tags = {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}