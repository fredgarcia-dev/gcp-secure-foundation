resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "primary" {
  name                     = "${var.name_prefix}-subnet-primary"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "secondary" {
  name                     = "${var.name_prefix}-subnet-secondary"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.secondary_region
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "router" {
  name    = "${var.name_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name_prefix}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name        = "${var.name_prefix}-allow-internal"
  network     = google_compute_network.vpc.name
  project     = var.project_id
  description = "Allow traffic within the VPC subnets only"
  priority    = 1000

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
}

resource "google_compute_firewall" "deny_all_ingress" {
  name        = "${var.name_prefix}-deny-all-ingress"
  network     = google_compute_network.vpc.name
  project     = var.project_id
  description = "Explicit deny all ingress from internet — defense in depth over implied rule"
  direction   = "INGRESS"
  priority    = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_google_apis_egress" {
  name        = "${var.name_prefix}-allow-google-apis-egress"
  network     = google_compute_network.vpc.name
  project     = var.project_id
  description = "Allow egress to Google APIs via Private Google Access IP ranges only"
  direction   = "EGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  # restricted.googleapis.com and private.googleapis.com ranges
  destination_ranges = ["199.36.153.8/30", "199.36.153.4/30"]
}
