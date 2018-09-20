variable "terraform_backend" {
  # Changes the backend for tracking state. Use "azurerm" if you'd like to track stage in an Azure Storage Container.
  # default = "azurerm"
  default = "local"
}

variable "client_id" {
  default = ""
}

variable "client_secret" {
  default = ""
}

variable "environment_tag" {
  default = "development"
}

variable "build_tag" {
  default = "ignite"
}

variable "agent_count" {
  default = 3
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "k8stest"
}

variable "cluster_name" {
  default = "k8stest"
}

variable "resource_group_name" {
  default = "ignite-azure-k8stest"
}

variable location {
  default = "East US"
}

variable function_app_content_zip_url {
  default = "https://github.com/zdeptawa/terraform-on-azure/raw/ignite-demo/demos/azurerm_tf_aks_ignite_demo/sample_data/ignite-tf-function-app-content.zip"
}
