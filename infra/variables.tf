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