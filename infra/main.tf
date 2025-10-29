# Terraform configuration and required providers
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# 1. CREATE AND CONFIGURE GCP PROJECT

provider "google" {
}

resource "google_project" "knowledgebase_project" {
  project_id = var.project_id
  name       = var.project_name
}

# List of APIs to enable for the project
locals {
  apis = [
    "serviceusage.googleapis.com",        # Required to enable other APIs
    "cloudresourcemanager.googleapis.com", # Project management
    "sqladmin.googleapis.com",            # Cloud SQL
    "run.googleapis.com",                 # Cloud Run for Search API / Sync Job
    "vpcaccess.googleapis.com",           # Required for VPC Connector
    "cloudscheduler.googleapis.com",      # Cloud Scheduler
    "secretmanager.googleapis.com",     # Secret Manager
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
  database_version = "POSTGRES_16"

  settings {
    tier = "db-f1-micro" # Start with a low-cost tier; upgrade as needed

    # No public IP, access is managed via Cloud SQL Auth Proxy
    ip_configuration {
      ipv4_enabled = false
    }
  }

  # Enable deletion protection for production
  deletion_protection = true

  depends_on = [google_project_service.default]
}

# Create a database within the instance
resource "google_sql_database" "default" {
  provider = google.project_kb
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

