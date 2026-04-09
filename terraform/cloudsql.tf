resource "random_password" "db_password" {
  length  = 24
  special = true
}

resource "google_sql_database_instance" "platform" {
  name             = "${var.environment}-platform-pg-${random_id.suffix.hex}"
  region           = var.region
  database_version = "POSTGRES_16"

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.db_tier
    disk_size         = var.db_disk_size_gb
    disk_type         = "PD_SSD"
    availability_type = var.db_availability_type

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "02:00"
      location                       = var.region
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    user_labels = local.common_labels
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "platform" {
  name     = "platform"
  instance = google_sql_database_instance.platform.name
}

resource "google_sql_user" "platform_app" {
  name     = "platform_app"
  instance = google_sql_database_instance.platform.name
  password = random_password.db_password.result
}

resource "google_secret_manager_secret" "platform_db_password" {
  secret_id = "platform-db-password"
  replication { 
      auto {}
  }
  labels = local.common_labels
}

resource "google_secret_manager_secret_version" "platform_db_password_v1" {
  secret      = google_secret_manager_secret.platform_db_password.id
  secret_data = random_password.db_password.result
}
