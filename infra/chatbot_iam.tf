# Grant the chatbot service account access to the secrets
resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each = toset([
    google_secret_manager_secret.webhook_url.secret_id,
    google_secret_manager_secret.n8n_user.secret_id,
    google_secret_manager_secret.n8n_password.secret_id
  ])
  provider  = google.project_kb
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.chat_bot_sa.email}"
}