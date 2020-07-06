output "client_key" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate}"
}

output "cluster_username" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
}

output "cluster_password" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
}

#output "k8s_nginx_lb_ip" {
#  value = "${kubernetes_service.nginx-service.load_balancer_ingress.0.ip}"
#}

output "configure" {
  value = <<CONFIGURE
Run the following commands to configure kubernetes client:
$ terraform output kube_config > ~/.kube/aksconfig
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
Run the following commands to connect to the k8s dashboard with the az cli:
$ az aks install-cli  # installs kubectl if needed
$ az aks get-credentials --resource-group k8s-demo-resource-group --name k8s-demo-cluster  # gets credentials
$ az aks browse --resource-group k8s-demo-resource-group --name k8s-demo-cluster  # opens dashboard

CONFIGURE
}