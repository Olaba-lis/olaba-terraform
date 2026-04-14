resource "kubernetes_namespace_v1" "tenant" {
  for_each = local.tenants

  metadata {
    name = each.value.namespace
    labels = {
      app         = "senaite"
      tenant      = each.value.short
      environment = var.environment
    }
  }

  depends_on = [time_sleep.wait_for_cluster]
}

resource "kubernetes_secret_v1" "origin_tls" {
  metadata {
    name      = "origin-tls"
    namespace = "default"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = cloudflare_origin_ca_certificate.origin_ca.certificate
    "tls.key" = tls_private_key.origin_ca.private_key_pem
  }

  depends_on = [time_sleep.wait_for_cluster]
}

resource "kubernetes_secret_v1" "tenant_admin" {
  for_each = local.tenants

  metadata {
    name      = "senaite-admin"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
  }

  data = {
    PASSWORD = random_password.senaite_admin.result
    SITE     = each.value.site_id
    ADDONS   = var.senaite_addons
  }

  depends_on = [kubernetes_namespace_v1.tenant]
}

resource "kubernetes_persistent_volume_claim_v1" "zeo_data" {
  for_each = local.tenants

  metadata {
    name      = "zeo-data"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "${var.tenant_storage_size_gb}Gi"
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.tenant]
}

resource "kubernetes_service_v1" "zeo" {
  for_each = local.tenants

  metadata {
    name      = "zeo"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
    labels = {
      app    = "zeo"
      tenant = each.value.short
    }
  }

  spec {
    selector = {
      app    = "zeo"
      tenant = each.value.short
    }

    port {
      name        = "zeo"
      port        = 8080
      target_port = 8080
    }
  }

  depends_on = [kubernetes_namespace_v1.tenant]
}

resource "kubernetes_stateful_set_v1" "zeo" {
  for_each = local.tenants

  metadata {
    name      = "zeo"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
    labels = {
      app    = "zeo"
      tenant = each.value.short
    }
  }

  spec {
    service_name = kubernetes_service_v1.zeo[each.key].metadata[0].name
    replicas     = 1

    selector {
      match_labels = {
        app    = "zeo"
        tenant = each.value.short
      }
    }

    template {
      metadata {
        labels = {
          app    = "zeo"
          tenant = each.value.short
        }
      }

      spec {
        container {
          name              = "zeo"
          image             = var.senaite_image
          image_pull_policy = "IfNotPresent"
          command           = ["zeo"]

          port {
            container_port = 8080
            name           = "zeo"
          }

          volume_mount {
            mount_path = "/data"
            name       = "zeo-data"
          }

          readiness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 20
            period_seconds        = 10
          }

          liveness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
          }
        }

        volume {
          name = "zeo-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.zeo_data[each.key].metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim_v1.zeo_data]
}

resource "kubernetes_service_v1" "app" {
  for_each = local.tenants

  metadata {
    name      = "senaite"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
    labels = {
      app    = "senaite"
      tenant = each.value.short
    }
    annotations = {
      "cloud.google.com/neg" = "{\"ingress\": true}"
    }
  }

  spec {
    selector = {
      app    = "senaite"
      tenant = each.value.short
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_namespace_v1.tenant]
}

resource "kubernetes_deployment_v1" "app" {
  for_each = local.tenants

  metadata {
    name      = "senaite"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
    labels = {
      app    = "senaite"
      tenant = each.value.short
    }
  }

  spec {
    replicas = var.tenant_app_replicas

    selector {
      match_labels = {
        app    = "senaite"
        tenant = each.value.short
      }
    }

    template {
      metadata {
        labels = {
          app    = "senaite"
          tenant = each.value.short
        }
      }

      spec {
        container {
          name              = "senaite"
          image             = var.senaite_image
          image_pull_policy = "IfNotPresent"

          env {
            name  = "ZEO_ADDRESS"
            value = "zeo:8080"
          }

          env {
            name = "SITE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.tenant_admin[each.key].metadata[0].name
                key  = "SITE"
              }
            }
          }

          env {
            name = "PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.tenant_admin[each.key].metadata[0].name
                key  = "PASSWORD"
              }
            }
          }

          env {
            name = "ADDONS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.tenant_admin[each.key].metadata[0].name
                key  = "ADDONS"
              }
            }
          }

          port {
            container_port = 8080
            name           = "http"
          }

          readiness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 15
          }

          liveness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 120
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
          }
        }
      }
    }
  }

  depends_on = [kubernetes_stateful_set_v1.zeo]
}

resource "kubernetes_ingress_v1" "tenant" {
  for_each = local.tenants

  metadata {
    name      = "${each.value.short}-ingress"
    namespace = kubernetes_namespace_v1.tenant[each.key].metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
      "kubernetes.io/ingress.allow-http"           = "false"
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.ingress_ip.name
    }
  }

  spec {
    tls {
      secret_name = kubernetes_secret_v1.origin_tls.metadata[0].name
    }

    rule {
      host = each.value.host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.app[each.key].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment_v1.app,
    kubernetes_secret_v1.origin_tls,
    cloudflare_record.tenant_hosts
  ]
}
