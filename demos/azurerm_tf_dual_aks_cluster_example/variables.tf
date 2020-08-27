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

variable "dns_prefix_east" {
  default = "k8sdemoeast"
}

variable "dns_prefix_west" {
  default = "k8sdemowest"
}

variable "cluster_name_east" {
  default = "k8s-demo-cluster-east"
}

variable "cluster_name_west" {
  default = "k8s-demo-cluster-west"
}

variable "resource_group_name_east" {
  default = "k8s-demo-resource-group-east"
}

variable "resource_group_name_west" {
  default = "k8s-demo-resource-group-west"
}

variable "location_east" {
  default = "eastus2"
}

variable "location_west" {
  default = "westus2"
}