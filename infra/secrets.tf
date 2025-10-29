# Generate a random password for the database
resource "random_password" "db_password" {
  length  = 20
  special = true
}

# Create a secret to store the database password
resource "google_secret_manager_secret" "db_password_secret" {
  provider  = google.project_kb
  secret_id = "db-postgres-password"

  replication {
    automatic = true
  }

  depends_on = [google_project_service.default]
}

# Store the generated password in the secret
resource "google_secret_manager_secret_version" "db_password_version" {
  provider      = google.project_kb
  secret        = google_secret_manager_secret.db_password_secret.id
  secret_data   = random_password.db_password.result
  is_secret_data = true
}
