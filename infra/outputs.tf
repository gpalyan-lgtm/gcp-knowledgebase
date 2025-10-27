# outputs.tf

# The ID of the newly created knowledgebase project.
output "project_id" {
  description = "The ID of the newly created knowledgebase project."
  value       = google_project.knowledgebase_project.project_id
}

# The connection name of the Cloud SQL instance, used for connecting via the Cloud SQL Auth Proxy.
output "cloud_sql_instance_name" {
  description = "The connection name of the Cloud SQL instance."
  value       = google_sql_database_instance.default.connection_name
}

# The public IP address of the Cloud SQL instance. Note: This is for initial setup and should be removed for production.
output "cloud_sql_instance_public_ip" {
  description = "The public IP of the Cloud SQL instance (for initial setup)."
  value       = google_sql_database_instance.default.public_ip_address
}