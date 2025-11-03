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
  depends_on = [google_project_service.default["vpcaccess.googleapis.com"]]
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

  source_subnetwork_ip_ranges_to_nat = "ALL_IP_RANGES"
  subnetwork {
    name = google_compute_subnetwork.vpc_connector_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.static_ip.self_link]
}

resource "google_compute_firewall" "deny-all-ingress" {
  provider = google.project_kb
  name    = "deny-all-ingress"
  network = google_compute_network.main.name
  direction = "INGRESS"
  deny {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-limited-egress" {
  provider = google.project_kb
  name    = "allow-limited-egress"
  network = google_compute_network.main.name
  direction = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  destination_ranges = ["0.0.0.0/0"]
}