resource "google_service_account" "chat_bot_sa" {
  provider = google.project_kb
  account_id   = "chat-bot-sa"
  display_name = "Chat Bot Service Account"
}

resource "google_cloud_run_v2_service" "chat_bot_service" {
  provider = google.project_kb
  name     = "google-chat-bot"
  location = var.gcp_region
  # TODO: Clarify ingress setting. Default is INGRESS_TRAFFIC_ALL (public). 
  # If only invoked by Google Chat, this might be appropriate, but ensure proper authentication. 
  # If strictly internal, consider INGRESS_TRAFFIC_INTERNAL_ONLY.
  template {
    containers {
      image = "gcr.io/${var.project_id}/google-chat-bot"
      ports {
        container_port = 8080
      }
      env {
        name = "WEBHOOK_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.webhook_url.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_USER"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.n8n_user.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.n8n_password.secret_id
            version = "latest"
          }
        }
      }
    }
    service_account = google_service_account.chat_bot_sa.email
  }
}