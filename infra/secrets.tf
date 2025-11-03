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

# --- Chatbot Secrets ---

resource "google_secret_manager_secret" "webhook_url" {
  provider  = google.project_kb
  secret_id = "chatbot-webhook-url"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "webhook_url_version" {
  provider    = google.project_kb
  secret      = google_secret_manager_secret.webhook_url.id
  secret_data = "DEINE_N8N_WEBHOOK_URL" # Bitte im Secret Manager aktualisieren
}

resource "google_secret_manager_secret" "n8n_user" {
  provider  = google.project_kb
  secret_id = "chatbot-n8n-user"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "n8n_user_version" {
  provider    = google.project_kb
  secret      = google_secret_manager_secret.n8n_user.id
  secret_data = "DEIN_N8N_BENUTZERNAME" # Bitte im Secret Manager aktualisieren
}

resource "google_secret_manager_secret" "n8n_password" {
  provider  = google.project_kb
  secret_id = "chatbot-n8n-password"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "n8n_password_version" {
  provider    = google.project_kb
  secret      = google_secret_manager_secret.n8n_password.id
  secret_data = "DEIN_N8N_PASSWORT" # Bitte im Secret Manager aktualisieren
  is_secret_data = true
}
