resource "google_project_service" "services" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "dns.googleapis.com",
    "gkebackup.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com"
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  common_labels = merge(var.labels, {
    environment = var.environment
    project     = var.project_id
  })

  tenants = {
    for host in var.tenant_hosts :
    host => {
      host      = host
      short     = replace(split(".", host)[0], "_", "-")
      namespace = substr(replace(replace(split(".", host)[0], "_", "-"), ".", "-"), 0, 63)
      site_id   = replace(split(".", host)[0], "-", "")
      tls_name  = "${substr(replace(replace(split(".", host)[0], "_", "-"), ".", "-"), 0, 40)}-tls"
    }
  }
}
