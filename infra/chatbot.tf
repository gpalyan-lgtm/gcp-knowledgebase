resource "google_project_service" "run_api" {
  project = var.project_id
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "workspace_marketplace_sdk" {
  project = var.project_id
  service = "appsmarket-component.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "chat_bot_sa" {
  provider = google.project_kb
  account_id   = "chat-bot-sa"
  display_name = "Chat Bot Service Account"
}

resource "google_cloud_run_v2_service" "chat_bot_service" {
  provider = google.project_kb
  name     = "google-chat-bot"
  location = var.gcp_region
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