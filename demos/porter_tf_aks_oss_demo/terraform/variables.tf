variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

variable "location" {
    default = "EastUS"
}

variable "environment_tag" {
    default = "demo"
}

variable "build_tag" {
    default = "demo01"
}

variable "kubernetes_version" {}

variable "agent_count" {
    default = 1
}

variable "ssh_public_key" {}

variable "dns_prefix" {
    default = "ossporterakstest"
}

variable "cluster_name" {
    default = "ossporterakstest"
}

variable "resource_group_name" {
    default = "ossporter_demo_rg"
}