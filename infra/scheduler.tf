# Service account for the scheduler to manage the SQL instance
resource "google_service_account" "sql_scheduler_sa" {
  provider     = google.project_kb
  account_id   = "sql-instance-scheduler"
  display_name = "Service Account for DB Scheduler"
}

# Grant the service account Cloud SQL Editor role
resource "google_project_iam_member" "sql_scheduler_iam" {
  provider = google.project_kb
  project  = google_project.knowledgebase_project.project_id
  role     = "roles/cloudsql.editor"
  member   = "serviceAccount:${google_service_account.sql_scheduler_sa.email}"
}

# Scheduler job to start the database instance
resource "google_cloud_scheduler_job" "start_db_instance" {
  provider    = google.project_kb
  name        = "start-postgres-instance"
  schedule    = "0 7 * * *" # 7:00 AM every day
  time_zone   = "Europe/Berlin"
  description = "Starts the PostgreSQL instance for the knowledge base."

  http_target {
    http_method = "PATCH"
    uri         = "https://sqladmin.googleapis.com/v1/projects/${google_project.knowledgebase_project.project_id}/instances/${google_sql_database_instance.default.name}"
    body        = base64encode("{\"settings\": {\"activationPolicy\": \"ALWAYS\"}}")

    oauth_token {
      service_account_email = google_service_account.sql_scheduler_sa.email
    }
  }

  depends_on = [google_project_iam_member.sql_scheduler_iam]
}

# --- Scheduler for Daily Sync Job ---
# Grant the scheduler SA permission to run the sync job
resource "google_cloud_run_v2_job_iam_member" "scheduler_invoker" {
  provider = google.project_kb
  project  = google_cloud_run_v2_job.sync_job.project
  location = google_cloud_run_v2_job.sync_job.location
  name     = google_cloud_run_v2_job.sync_job.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.sql_scheduler_sa.email}"
}

# Scheduler job to trigger the daily sync
resource "google_cloud_scheduler_job" "trigger_sync_job" {
  provider    = google.project_kb
  name        = "trigger-daily-bq-to-sql-sync"
  schedule    = "0 3 * * *" # 3:00 AM every day
  time_zone   = "Europe/Berlin"
  description = "Triggers the daily BigQuery to PostgreSQL sync job."

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_v2_job.sync_job.uri}/executions"

    oidc_token {
      service_account_email = google_service_account.sql_scheduler_sa.email
    }
  }

  depends_on = [google_cloud_run_v2_job_iam_member.scheduler_invoker]
}