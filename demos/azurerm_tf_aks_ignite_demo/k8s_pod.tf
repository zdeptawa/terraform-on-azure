# Set up the provider for k8s
provider "kubernetes" {
  host = azurerm_kubernetes_cluster.k8s.kube_config.0.host

  #username               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
  #password               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"

  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

# Create the k8s nginx pod
# resource "kubernetes_pod" "ignite-pod" {
#   metadata {
#     name = "ignite-nginx-pod"
#     labels = {
#       app = "nginx"
#     }
#   }

#   spec {
#     container {
#       image = "nginx:1.7.9"
#       name  = "nginx"
#     }
#   }
# }

resource "kubernetes_pod" "ignite-pod" {
  metadata {
    name = "ignite-nginx-pod"
    labels = {
      app = "nginx"
    }
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "nginx"

      # env {
      #   name  = "environment"
      #   value = "development"
      # }

      # port {
      #   container_port = 8080
      # }

      # liveness_probe {
      #   http_get {
      #     path = "/nginx_status"
      #     port = 80

      #     http_header {
      #       name  = "X-Custom-Header"
      #       value = "Awesome"
      #     }
      #   }

      #   initial_delay_seconds = 3
      #   period_seconds        = 3
      }
    }
    
    # dns_config {
    #   nameservers = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
    #   searches    = ["example.com"]

    #   option {
    #     name  = "ndots"
    #     value = 1
    #   }

    #   option {
    #     name = "use-vc"
    #   }
    # }

    # dns_policy = "None"
    #}
}

# Create the k8s nginx web service
resource "kubernetes_service" "ignite-web" {
  metadata {
    name = "ignite-nginx-service"
  }

  spec {
    selector = {
      app = kubernetes_pod.ignite-pod.metadata.0.labels.app
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}