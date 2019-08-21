provider "azurerm" {
    version = "~>1.5"
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

terraform {
    required_version = "~>0.11"
    backend "azurerm" {}
}

resource "azurerm_resource_group" "demo01_resource_group" {
  name     = "demo01_resource_group"
  location = "eastus"

  tags {
    environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}