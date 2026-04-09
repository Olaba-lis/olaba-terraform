resource "google_secret_manager_secret" "senaite_admin_password" {
  secret_id = "senaite-admin-password"
  replication { auto {} }

  labels = local.common_labels
}

resource "google_secret_manager_secret" "smtp_password" {
  secret_id = "smtp-password"
  replication { auto {} }

  labels = local.common_labels
}

resource "google_secret_manager_secret" "tenant_registry" {
  secret_id = "tenant-registry"
  replication { auto {} }

  labels = local.common_labels
}
