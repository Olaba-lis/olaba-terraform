resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "dns.googleapis.com",
    "cloudkms.googleapis.com",
    "gkebackup.googleapis.com",
    "binaryauthorization.googleapis.com",
    "containeranalysis.googleapis.com"
  ])

  service = each.key

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
}
