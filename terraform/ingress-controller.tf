resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_manifest" "ingress_nginx" {
  manifest = yamldecode(file("${path.module}/k8s/ingress-nginx.yaml"))
}