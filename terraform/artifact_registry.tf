resource "google_artifact_registry_repository" "senaite" {
  location      = var.region
  repository_id = var.artifact_registry_repo
  description   = "Container images for SENAITE platform"
  format        = "DOCKER"

  labels = local.common_labels
}
