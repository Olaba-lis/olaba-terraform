resource "cloudflare_dns_record" "tenant_hosts" {
  for_each = toset(var.tenant_hosts)

  zone_id = var.cloudflare_zone_id
  name    = each.value
  content = google_compute_global_address.ingress_ip.address
  type    = "A"
  ttl     = 1
  proxied = true
}
