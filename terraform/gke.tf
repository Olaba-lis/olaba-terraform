resource "google_service_account" "gke_nodes" {
  account_id   = "gke-ops-${var.environment}"
  display_name = "GKE operations service account"
}

resource "google_project_iam_member" "gke_sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_sa_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "autopilot" {
  provider = google-beta

  name     = var.gke_cluster_name
  location = var.region

  enable_autopilot    = true
  deletion_protection = var.deletion_protection
  network             = google_compute_network.vpc.id
  subnetwork          = google_compute_subnetwork.main.id
  datapath_provider   = "ADVANCED_DATAPATH"

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = var.gke_release_channel
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = var.enable_binary_authorization ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  depends_on = [
    google_project_service.services,
    google_project_iam_member.gke_sa_logging,
    google_project_iam_member.gke_sa_monitoring
  ]
}

resource "time_sleep" "wait_for_cluster" {
  depends_on      = [google_container_cluster.autopilot]
  create_duration = "90s"
}
