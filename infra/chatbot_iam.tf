resource "google_cloud_run_service_iam_member" "allow_public_invocations" {
  location = google_cloud_run_v2_service.chat_bot_service.location
  project  = google_cloud_run_v2_service.chat_bot_service.project
  service  = google_cloud_run_v2_service.chat_bot_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Grant the chatbot service account access to the secrets
resource "google_secret_manager_secret_iam_member" "webhook_url_accessor" {
  provider = google.project_kb
  secret_id = google_secret_manager_secret.webhook_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.chat_bot_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "n8n_user_accessor" {
  provider = google.project_kb
  secret_id = google_secret_manager_secret.n8n_user.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.chat_bot_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "n8n_password_accessor" {
  provider = google.project_kb
  secret_id = google_secret_manager_secret.n8n_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.chat_bot_sa.email}"
}