resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "app-ingress"
    namespace = "default"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "lab01.olaba-lis.com"

      http {
        path {
          path = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "test"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}