resource "random_password" "senaite_admin" {
  length           = 24
  special          = true
  override_special = "@#%^*()-_=+"
}

resource "random_password" "smtp_password" {
  length           = 24
  special          = true
  override_special = "@#%^*()-_=+"
}

resource "google_secret_manager_secret" "senaite_admin_password" {
  secret_id = "senaite-admin-password"

  replication {
    auto {}
  }

  labels = local.common_labels
}

resource "google_secret_manager_secret_version" "senaite_admin_password_v1" {
  secret      = google_secret_manager_secret.senaite_admin_password.id
  secret_data = random_password.senaite_admin.result
}

resource "google_secret_manager_secret" "smtp_password" {
  secret_id = "smtp-password"

  replication {
    auto {}
  }

  labels = local.common_labels
}

resource "google_secret_manager_secret_version" "smtp_password_v1" {
  secret      = google_secret_manager_secret.smtp_password.id
  secret_data = random_password.smtp_password.result
}

resource "google_secret_manager_secret" "tenant_registry" {
  secret_id = "tenant-registry"

  replication {
    auto {}
  }

  labels = local.common_labels
}

resource "google_secret_manager_secret_version" "tenant_registry_v1" {
  secret_data = jsonencode({ tenants = var.tenant_hosts })
  secret      = google_secret_manager_secret.tenant_registry.id
}
