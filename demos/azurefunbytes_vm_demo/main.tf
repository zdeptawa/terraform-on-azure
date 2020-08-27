provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azfunbytes_resource_group" {
  name     = "azfunbytes_demo"
  location = "East US 2"

  tags     = { environment = "demo", build = "azfunbytes" }
}

resource "azurerm_virtual_network" "azfunbytes_network" {
  name                = "azfunbytes-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azfunbytes_resource_group.location
  resource_group_name = azurerm_resource_group.azfunbytes_resource_group.name
  tags     = { environment = "demo", build = "azfunbytes" }
}

resource "azurerm_subnet" "azfunbytes_internal_subnet" {
  name                 = "azfunbytes_internal"
  resource_group_name  = azurerm_resource_group.azfunbytes_resource_group.name
  virtual_network_name = azurerm_virtual_network.azfunbytes_network.name
  address_prefixes     = [ "10.0.2.0/24" ]
}

resource "azurerm_network_security_group" "azfunbytes_sg" {
    name                = "azfunbytes_security_group"
    location            = azurerm_resource_group.azfunbytes_resource_group.location
    resource_group_name = azurerm_resource_group.azfunbytes_resource_group.name
    
    security_rule {
        name                       = "HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = { environment = "demo", build = "azfunbytes" }
}

resource "azurerm_public_ip" "azfunbytes_public_ip" {
    name                         = "azfunbytes_public_ip"
    location                     = azurerm_resource_group.azfunbytes_resource_group.location
    resource_group_name          = azurerm_resource_group.azfunbytes_resource_group.name
    allocation_method            = "Dynamic"

    tags = { environment = "demo", build = "azfunbytes" }
}

resource "azurerm_network_interface" "azfunbytes_interface" {
  name                = "azfunbytes-nic"
  location            = azurerm_resource_group.azfunbytes_resource_group.location
  resource_group_name = azurerm_resource_group.azfunbytes_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azfunbytes_internal_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azfunbytes_public_ip.id
  }

  tags     = { environment = "demo", build = "azfunbytes" }
}

resource "azurerm_network_interface_security_group_association" "azfunbytes_sg_assoc" {
    network_interface_id      = azurerm_network_interface.azfunbytes_interface.id
    network_security_group_id = azurerm_network_security_group.azfunbytes_sg.id
}

resource "azurerm_linux_virtual_machine" "azfunbytes_linux_vm" {
  name                = "azfunbytes-linux-machine"
  resource_group_name = azurerm_resource_group.azfunbytes_resource_group.name
  location            = azurerm_resource_group.azfunbytes_resource_group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.azfunbytes_interface.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags     = { environment = "demo", build = "azfunbytes" }
}

resource "azurerm_virtual_machine_extension" "azfunbytes_vm_web_build" {
  name                 = "azfunbytes_vm_web_build"
  virtual_machine_id   = azurerm_linux_virtual_machine.azfunbytes_linux_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update -y && sudo apt-get install nginx -y"
    }
SETTINGS

  tags = { environment = "demo", build = "azfunbytes" }
}
