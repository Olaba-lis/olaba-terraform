resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  values = [
    yamlencode({
      installCRDs = true
    })
  ]
}

# 🔥 WAIT FOR CRDs TO BE READY
resource "time_sleep" "wait_cert_manager" {
  depends_on = [helm_release.cert_manager]

  create_duration = "60s"
}

resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [time_sleep.wait_cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "letsencrypt"
    }

    spec = {
      acme = {
        email  = "admin@olaba-lis.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"

        privateKeySecretRef = {
          name = "letsencrypt"
        }

        solvers = [
          {
            dns01 = {
              cloudflare = {
                email = "admin@olaba-lis.com"
                apiTokenSecretRef = {
                  name = "cloudflare-api-token"
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}