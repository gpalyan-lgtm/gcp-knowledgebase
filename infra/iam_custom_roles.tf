
resource "google_project_iam_custom_role" "sql_instance_scheduler_role" {
  provider    = google.project_kb
  role_id     = "sqlInstanceScheduler"
  title       = "SQL Instance Scheduler"
  description = "Custom role for the Cloud SQL instance scheduler to start and stop instances."
  permissions = [
    "cloudsql.instances.get",
    "cloudsql.instances.update"
  ]
}
