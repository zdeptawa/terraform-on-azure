variable "client_id" {
  default = ""
}

variable "client_secret" {
  default = ""
}

variable "resource_group_name" {
  default = "demo_win_resource_group"
}

variable location {
  default = "East US 2"
}

variable "address_space" {
    default = "10.0.0.0/16"
}
variable "subnet_prefixes" {
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "subnet_names" {
    default = ["demo_win_public_subnet", "demo_win_private_subnet"]
}

variable "vnet_name" {
    default = "demo_win_network"
}

variable "public_subnet_name" {
    default = "demo_win_public_subnet"
}

variable "public_subnet_prefix" {
    default = "10.0.1.0/24"
}

variable "private_subnet_name" {
    default = "demo_win_private_subnet"
}

variable "private_subnet_prefix" {
    default = "10.0.2.0/24"
}

variable "public_security_group_name" {
    default = "demo_win_public_security_group"
}

variable "private_security_group_name" {
    default = "demo_win_private_security_group"
}

variable "network_interface_name" {
    default = "demo_win_network_interface"
}

variable "network_interface_db_name" {
    default = "demo_win_network_interface_db"
}

variable "ip_configuration_name" {
    default = "demo_win_ip_configuration"
}

variable "ip_configuration_db_name" {
    default = "demo_win_ip_configuration_db"
}

variable "web_managed_disk_name" {
    default = "demo_win_managed_disk"
}

variable "db_managed_disk_name" {
    default = "demo_win_db_managed_disk"
}

variable "web_server_name" {
    default = "demo_win_web01"
}

variable "db_server_name" {
    default = "demo_win_db01"
}

variable "web_vm_size" {
    default = "Standard_DS1_v2"
}

variable "db_vm_size" {
    default = "Standard_DS1_v2"
}

variable "lb_prefix" {
    default = "demo-win"
}

variable "lb_frontend_name" {
    default = "demo-win-public-vip"
}

variable "environment_tag" {
  default = "demo-app-win"
}

variable "build_tag" {
  default = "devops-win-demo-app"
}