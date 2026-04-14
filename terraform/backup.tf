resource "google_gke_backup_backup_plan" "cluster_daily" {
  count    = var.enable_backup_for_gke ? 1 : 0
  provider = google-beta

  name     = "${var.gke_cluster_name}-daily"
  cluster  = google_container_cluster.autopilot.id
  location = var.region

  retention_policy {
    backup_delete_lock_days = 7
    backup_retain_days      = 30
  }

  backup_schedule {
    cron_schedule = "0 2 * * *"
    paused        = false
  }

  backup_config {
    include_volume_data = true
    include_secrets     = true
    all_namespaces      = true
  }

  labels = local.common_labels

  depends_on = [time_sleep.wait_for_cluster]
}
