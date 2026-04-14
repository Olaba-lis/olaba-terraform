data "google_client_config" "default" {}

provider "kubernetes" {
  host = "https://${google_container_cluster.autopilot.endpoint}"

  cluster_ca_certificate = base64decode(
    google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate
  )

  token = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host = "https://${google_container_cluster.autopilot.endpoint}"

    cluster_ca_certificate = base64decode(
      google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate
    )

    token = data.google_client_config.default.access_token
  }
}