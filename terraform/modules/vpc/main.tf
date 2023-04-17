// vpc module
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name                     = var.subnet_name
  ip_cidr_range            = var.cidr_range
  region                   = var.gcp_region
  network                  = google_compute_network.vpc.id
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = var.cidr_pods
  }
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.cidr_services
  }
}

resource "google_compute_subnetwork" "network-managed-proxy" {
  name          = var.subnet_name_proxy
  ip_cidr_range = var.cidr_range_proxy
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}
