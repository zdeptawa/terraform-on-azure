# East US AKS Cluster Info
output "client_key_east" {
  value = "${azurerm_kubernetes_cluster.k8s_east.kube_config.0.client_key}"
}

output "client_certificate_east" {
  value = "${azurerm_kubernetes_cluster.k8s_east.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate_east" {
  value = "${azurerm_kubernetes_cluster.k8s_east.kube_config.0.cluster_ca_certificate}"
}

output "cluster_username_east" {
  value = "${azurerm_kubernetes_cluster.k8s_east.kube_config.0.username}"
}

output "cluster_password_east" {
  value = "${azurerm_kubernetes_cluster.k8s_east.kube_config.0.password}"
}

output "kube_config_east" {
  value = "${azurerm_kubernetes_cluster.k8s_east.kube_config_raw}"
}

output "host_east" {
  value = "${azurerm_kubernetes_cluster.k8s_east.kube_config.0.host}"
}

# West US AKS Cluster Info
output "client_key_west" {
  value = "${azurerm_kubernetes_cluster.k8s_west.kube_config.0.client_key}"
}

output "client_certificate_west" {
  value = "${azurerm_kubernetes_cluster.k8s_west.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate_west" {
  value = "${azurerm_kubernetes_cluster.k8s_west.kube_config.0.cluster_ca_certificate}"
}

output "cluster_username_west" {
  value = "${azurerm_kubernetes_cluster.k8s_west.kube_config.0.username}"
}

output "cluster_password_west" {
  value = "${azurerm_kubernetes_cluster.k8s_west.kube_config.0.password}"
}

output "kube_config_west" {
  value = "${azurerm_kubernetes_cluster.k8s_west.kube_config_raw}"
}

output "host_west" {
  value = "${azurerm_kubernetes_cluster.k8s_west.kube_config.0.host}"
}

#output "k8s_nginx_lb_ip" {
#  value = "${kubernetes_service.nginx-service.load_balancer_ingress.0.ip}"
#}

output "configure_east" {
  value = <<CONFIGURE
Run the following commands to configure the kubernetes client for the east cluster:
$ terraform output kube_config_east > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig
Run the following commands to configure the kubernetes client for the west cluster:
$ terraform output kube_config_east > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig
Test configuration using kubectl
$ kubectl config view # view current kubectl context
$ kubectl get nodes # view k8s nodes
$ kubectl get services # view k8s services
Set up kubectl proxy
$ kubectl proxy
$ open 'http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=default'
You can also connect using the azcli:

CONFIGURE
}

output "az_cli" {
  value = <<CONFIGURE
Run the following commands to connect to the k8s-east dashboard with the az cli:
$ az aks install-cli  # installs kubectl if needed
$ az aks get-credentials --resource-group k8s-demo-resource-group-east --name k8s-demo-cluster-east  # gets credentials
$ az aks browse --resource-group k8s-demo-resource-group-east --name k8s-demo-cluster-east  # opens dashboard
Run the following commands to connect to the k8s-west dashboard with the az cli:
$ az aks install-cli  # installs kubectl if needed
$ az aks get-credentials --resource-group k8s-demo-resource-group-west --name k8s-demo-cluster-west  # gets credentials
$ az aks browse --resource-group k8s-demo-resource-group-wes --name k8s-demo-cluster-west  # opens dashboard

CONFIGURE
}