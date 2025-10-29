# Create a dedicated VPC for the application
resource "google_compute_network" "main" {
  provider                = google.project_kb
  name                    = "kb-vpc"
  auto_create_subnetworks = false
}

# Create a subnetwork for the VPC Access Connector
resource "google_compute_subnetwork" "vpc_connector_subnet" {
  provider      = google.project_kb
  name          = "vpc-connector-subnet"
  ip_cidr_range = "10.8.0.0/28"
  region        = var.gcp_region
  network       = google_compute_network.main.id
}

# Create the Serverless VPC Access Connector
resource "google_vpc_access_connector" "main" {
  provider       = google.project_kb
  name           = "kb-vpc-connector"
  region         = var.gcp_region
  subnet {
    name = google_compute_subnetwork.vpc_connector_subnet.name
  }
  machine_type = "e2-micro"
  depends_on = [google_project_service.default] # Depends on vpcaccess.googleapis.com
}

# Reserve a static external IP address
resource "google_compute_address" "static_ip" {
  provider = google.project_kb
  name     = "cloud-run-static-ip"
  region   = var.gcp_region
}

# Create a Cloud Router
resource "google_compute_router" "main" {
  provider = google.project_kb
  name     = "kb-router"
  region   = var.gcp_region
  network  = google_compute_network.main.id
}

# Create a Cloud NAT gateway for the static outbound IP
resource "google_compute_router_nat" "main" {
  provider                               = google.project_kb
  name                                   = "kb-nat-gateway"
  router                                 = google_compute_router.main.name
  region                                 = google_compute_router.main.region
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  subnetwork {
    name                    = google_compute_subnetwork.vpc_connector_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.static_ip.self_link]
}
