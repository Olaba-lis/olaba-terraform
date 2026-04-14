output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "gke_cluster_name" {
  value = google_container_cluster.autopilot.name
}

output "gke_get_credentials" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.autopilot.name} --region ${var.region} --project ${var.project_id}"
}

output "ingress_ip" {
  value = google_compute_global_address.ingress_ip.address
}

output "artifact_registry_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.senaite.repository_id}"
}

output "tenant_urls" {
  value = [for host in var.tenant_hosts : "https://${host}"]
}

output "secret_manager_admin_password_secret" {
  value = google_secret_manager_secret.senaite_admin_password.secret_id
}

output "cloudsql_private_connection_name" {
  value = try(google_sql_database_instance.platform[0].connection_name, null)
}

output "cloudsql_private_ip" {
  value = try(google_sql_database_instance.platform[0].private_ip_address, null)
}
