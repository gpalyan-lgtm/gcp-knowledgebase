# variables.tf

# The ID of the billing account to associate with the new project.
variable "billing_account_id" {
  description = "The Billing Account ID to be associated with the new project."
  type        = string
  # Example: "012345-6789AB-CDEF01"
}

# The desired unique identifier for your new Google Cloud project.
variable "project_id" {
  description = "The unique ID for your new 'Knowledgebase' project."
  type        = string
  default     = "kb-application-project" # IMPORTANT: CHANGE THIS VALUE to a unique project ID.
}

# The user-friendly display name for the new project.
variable "project_name" {
  description = "The display name for your new project."
  type        = string
  default     = "Knowledgebase Application"
}

# The GCP region where most of the resources will be deployed.
variable "gcp_region" {
  description = "The region for most resources."
  type        = string
  default     = "europe-west3" # e.g., Frankfurt, Germany
}

# The name for the PostgreSQL database.
variable "db_name" {
  description = "The name of the PostgreSQL database."
  type        = string
  default     = "knowledgebase_db"
}

# The password for the 'postgres' superuser.
variable "db_password" {
  description = "The password for the 'postgres' admin user."
  type        = string
  sensitive   = true # This ensures the password is not displayed in Terraform's output.
}