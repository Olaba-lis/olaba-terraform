resource "tls_private_key" "origin_ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "origin_ca" {
  private_key_pem = tls_private_key.origin_ca.private_key_pem

  subject {
    common_name  = var.domain
    organization = var.project_name
  }

  dns_names = concat([var.domain, "*.${var.domain}"], var.tenant_hosts)
}

resource "cloudflare_origin_ca_certificate" "origin_ca" {
  csr                = tls_cert_request.origin_ca.cert_request_pem
  hostnames          = concat([var.domain, "*.${var.domain}"], var.tenant_hosts)
  request_type       = "origin-rsa"
  requested_validity = 5475
}

resource "cloudflare_record" "tenant_hosts" {
  for_each = local.tenants

  zone_id = var.cloudflare_zone_id
  name    = each.value.host
  type    = "A"
  ttl     = 1
  proxied = true
  content = google_compute_global_address.ingress_ip.address
}
