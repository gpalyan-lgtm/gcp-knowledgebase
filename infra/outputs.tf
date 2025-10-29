# The ID of the newly created knowledgebase project.
output "project_id" {
  description = "The ID of the knowledgebase project."
  value       = google_project.knowledgebase_project.project_id
}

# The GCP region where resources are deployed.
output "gcp_region" {
  description = "The GCP region where the resources are deployed."
  value       = var.gcp_region
}

# The connection name of the Cloud SQL instance, used for connecting via the Cloud SQL Auth Proxy.
output "cloud_sql_instance_name" {
  description = "The connection name of the Cloud SQL instance."
  value       = google_sql_database_instance.default.connection_name
}

# The URL of the deployed Knowledgebase API service.
output "api_service_url" {
  description = "The main endpoint for the Knowledgebase API service."
  value       = google_cloud_run_v2_service.api_service.uri
}

# The static IP address used for outbound traffic from the Cloud Run service.
output "static_outbound_ip" {
  description = "Static IP for egress traffic from the serverless VPC connector."
  value       = google_compute_address.static_ip.address
}

# The name of the secret in Secret Manager containing the database password.
output "db_password_secret_name" {
  description = "The name of the Secret Manager secret for the DB password."
  value       = google_secret_manager_secret.db_password_secret.secret_id
}

# The email of the service account used by the Knowledgebase API.
output "api_service_account_email" {
  description = "The service account email for the main API service."
  value       = google_service_account.api_sa.email
}