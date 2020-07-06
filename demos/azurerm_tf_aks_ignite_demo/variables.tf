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
  default = "ignite-demo"
}

variable "agent_count" {
  default = 3
}

variable "admin_username" {
  default = "ubuntu"
}

variable "dns_prefix" {
  default = "ignitek8sdemo"
}

variable "cluster_name" {
  default = "ignite-demo-cluster"
}

variable "resource_group_name" {
  default = "ignite-demo-resource-group"
}

variable location {
  default = "East US"
}

variable function_app_content_zip_url {
  default = "https://github.com/zdeptawa/terraform-on-azure/raw/ignite-demo/demos/azurerm_tf_aks_ignite_demo/sample_data/ignite-tf-function-app-content.zip"
}
