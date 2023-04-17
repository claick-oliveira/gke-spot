// vpc module
output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name
}

output "subnet_proxy_name" {
  description = "The name of the proxy subnet"
  value       = google_compute_subnetwork.network-managed-proxy.name
}

output "cidr" {
  description = "The CIDR of the subnet"
  value       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.ip_cidr_range
}
