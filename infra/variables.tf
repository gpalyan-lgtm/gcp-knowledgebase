# The ID of the billing account to associate with the new project.
variable "billing_account_id" {
  description = "The Billing Account ID to be associated with the new project."
  type        = string
  # Example: "012345-6789AB-CDEF01"
}

# The desired unique identifier for new Google Cloud project.
variable "project_id" {
  description = "The unique ID for 'Knowledgebase' project."
  type        = string
  default     = "kb-application-project"
}

# The user-friendly display name for the new project.
variable "project_name" {
  description = "The display name for your new project."
  type        = string
  default     = "Knowledgebase"
}

# The GCP region where the resources will be deployed.
variable "gcp_region" {
  description = "The region for the resources."
  type        = string
  default     = "europe-west3"
}

# The name for the PostgreSQL database.
variable "db_name" {
  description = "The name of the PostgreSQL database."
  type        = string
  default     = "knowledgebase_db"
}

variable "sync_job_image" {
  description = "The container image for the daily sync job."
  type        = string
  default     = "gcr.io/cloud-run/hello" # Placeholder - Replace with your actual sync job image
}

variable "api_service_image" {
  description = "The container image for the knowledgebase API service."
  type        = string
  default     = "gcr.io/cloud-run/hello" # Placeholder - Replace with your actual API service image
}

variable "cloud_sql_proxy_image" {
  description = "The container image for the Cloud SQL proxy."
  type        = string
  default     = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:latest"
}

variable "chatbot_service_account_email" {
  description = "The full email of the service account from the external chatbot project that is allowed to invoke the API."
  type        = string
  default     = "chatbot-client-sa@project-3.iam.gserviceaccount.com" # Placeholder
}