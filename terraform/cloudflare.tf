resource "cloudflare_record" "tenant_hosts" {
  for_each = toset(var.tenant_hosts)

  zone_id = var.cloudflare_zone_id
  name    = each.value
  content = kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].ip
  type    = "A"
  ttl     = 1
  proxied = true
}
