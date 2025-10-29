#Component 1: Daily Sync Job
resource "google_cloud_run_v2_job" "sync_job" {
  provider = google.project_kb
  name     = "daily-bq-to-sql-sync"
  location = var.gcp_region

  template {
    template {
      service_account = "sync-job-sa@project-2.iam.gserviceaccount.com"
      containers {
        name  = "sync-app-container"
        image = "gcr.io/cloud-run/hello" # Placeholder
        env {
          name  = "DB_HOST"
          value = "127.0.0.1"
        }
      }
      containers {
        name    = "cloud-sql-proxy"
        image   = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:latest"
        command = ["/cloud-sql-proxy", "--structured-logs", "--port=5432", google_sql_database_instance.default.connection_name]
      }
      vpc_access {
        connector = google_vpc_access_connector.main.id
        egress    = "PRIVATE_RANGES_ONLY"
      }
    }
  }
}

#Component 2: Knowledgebase API Service

# Dedicated Service Account for the API Service itself
resource "google_service_account" "api_sa" {
  provider     = google.project_kb
  account_id   = "kb-api-service-sa"
  display_name = "Service Account for Knowledgebase API"
}

# Grant the API's own SA the Cloud SQL Client role
resource "google_project_iam_member" "api_sql_client" {
  provider = google.project_kb
  project  = google_project.knowledgebase_project.project_id
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_cloud_run_v2_service" "api_service" {
  provider = google.project_kb
  name     = "knowledgebase-api-service"
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_ALL" # Allows public access, secured by IAM

  template {
    service_account = google_service_account.api_sa.email
    containers {
      name  = "api-app-container"
      image = "gcr.io/cloud-run/hello" # Placeholder: Replace with your API image
      env {
        name  = "DB_HOST"
        value = "127.0.0.1"
      }
      env {
        name  = "DB_USER"
        value = "postgres"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.default.name
      }
      env {
        name  = "GCP_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "GCP_REGION"
        value = var.gcp_region
      }
    }
    containers {
      name    = "cloud-sql-proxy"
      image   = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:latest"
      command = ["/cloud-sql-proxy", "--structured-logs", "--port=5432", google_sql_database_instance.default.connection_name]
    }
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }
}

# --- IAM Bindings for External Service Accounts ---

# Grant Cloud SQL Client & BQ Viewer to the Sync Job SA
resource "google_project_iam_member" "sync_job_permissions" {
  for_each = toset(["roles/cloudsql.client", "roles/bigquery.dataViewer"])
  provider = google.project_kb
  project  = google_project.knowledgebase_project.project_id
  role     = each.key
  member   = "serviceAccount:sync-job-sa@project-2.iam.gserviceaccount.com"
}

# Grant the external Chatbot SA from Project 3 permission to invoke our new API service
resource "google_cloud_run_v2_service_iam_member" "chatbot_client_api_invoker" {
  provider = google.project_kb
  project  = google_cloud_run_v2_service.api_service.project
  location = google_cloud_run_v2_service.api_service.location
  name     = google_cloud_run_v2_service.api_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:chatbot-client-sa@project-3.iam.gserviceaccount.com"
}
