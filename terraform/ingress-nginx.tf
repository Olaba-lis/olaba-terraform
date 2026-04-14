resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  timeout          = 1200
  wait             = true

  values = [yamlencode({
    controller = {
      service = {
        type           = "LoadBalancer"
        loadBalancerIP = google_compute_address.nginx_ingress_ip.address
      }
      admissionWebhooks = {
        enabled = true
      }
      metrics = {
        enabled = true
      }
    }
  })]

  depends_on = [time_sleep.wait_for_cluster]
}
