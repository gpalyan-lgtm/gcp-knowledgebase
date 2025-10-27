# main.tf

# ----------------------------------------------------------
# Terraform configuration and required providers
# ----------------------------------------------------------
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# ----------------------------------------------------------
# 1. CREATE AND CONFIGURE GCP PROJECT
# ----------------------------------------------------------

provider "google" {
  # No project specified initially; required to create a new project
}

resource "google_project" "knowledgebase_project" {
  project_id = var.project_id
  name       = var.project_name
  folder_id  = null # Optional: specify if you use a folder structure
}

# List of APIs to enable for the project
locals {
  apis = [
    "serviceusage.googleapis.com",        # Required to enable other APIs
    "cloudresourcemanager.googleapis.com", # Project management
    "sqladmin.googleapis.com",            # Cloud SQL
    "run.googleapis.com",                 # Cloud Run for Search API / Sync Job
    "cloudfunctions.googleapis.com",      # Cloud Functions for ingestion
    "cloudscheduler.googleapis.com",      # Cloud Scheduler
    "aiplatform.googleapis.com"           # Vertex AI (Embeddings, Gemini)
  ]
}

# Enable all required APIs in the project
resource "google_project_service" "default" {
  project = google_project.knowledgebase_project.project_id
  depends_on = [google_project.knowledgebase_project]

  for_each = toset(local.apis)
  service  = each.key

  # Prevent Terraform from disabling services on destroy
  disable_on_destroy = false
}

# ----------------------------------------------------------
# 2. CREATE CLOUD SQL INSTANCE WITH POSTGRESQL
# ----------------------------------------------------------

# Provider configured to use the newly created project
provider "google" {
  alias   = "project_kb"
  project = google_project.knowledgebase_project.project_id
}

# Generate a random suffix for the instance name to avoid collisions
resource "random_id" "instance_suffix" {
  byte_length = 4
}

# Create Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "default" {
  provider = google.project_kb
  name     = "kb-postgres-instance-${random_id.instance_suffix.hex}"
  region   = var.gcp_region
  database_version = "POSTGRES_15"

  settings {
    tier = "db-f1-micro" # Start with a low-cost tier; upgrade as needed

    # Public IP required for Terraform PostgreSQL provider
    # For production, use Cloud SQL Proxy instead
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0" # Restrict to your IP in production
      }
    }
  }

  # Disable deletion protection for testing; enable in production
  deletion_protection = false

  depends_on = [google_project_service.default]
}

# Create a database within the instance
resource "google_sql_database" "default" {
  provider = google.project_kb
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

# Create the 'postgres' admin user
resource "google_sql_user" "default" {
  provider = google.project_kb
  name     = "postgres"
  instance = google_sql_database_instance.default.name
  password = var.db_password
}

# ----------------------------------------------------------
# 3. INSTALL PGVECTOR EXTENSION USING POSTGRESQL PROVIDER
# ----------------------------------------------------------

# Configure PostgreSQL provider to connect to the newly created instance
provider "postgresql" {
  host     = google_sql_database_instance.default.public_ip_address
  port     = 5432
  database = google_sql_database.default.name
  username = google_sql_user.default.name
  password = google_sql_user.default.password
  sslmode  = "disable" # Use 'require' in production

  depends_on = [google_sql_user.default]
}

# Install pgvector extension in the database
resource "postgresql_extension" "pgvector" {
  provider = postgresql
  name     = "vector"
}
