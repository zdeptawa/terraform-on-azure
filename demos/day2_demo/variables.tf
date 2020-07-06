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
  default = "k8sdemo"
}

variable "agent_count" {
  default = 3
}

variable "admin_username" {
  default = "ubuntu"
}

variable "dns_prefix" {
  default = "k8sdemo"
}

variable "cluster_name" {
  default = "k8s-demo-cluster"
}

variable "resource_group_name" {
  default = "k8s-demo-resource-group"
}

variable location {
  default = "East US"
}