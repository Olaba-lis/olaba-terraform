resource "cloudflare_record" "tenant_hosts" {
  for_each = local.tenants

  zone_id = var.cloudflare_zone_id
  name    = each.value.host
  type    = "A"
  ttl     = 1
  proxied = true
  content = google_compute_address.nginx_ingress_ip.address
}
