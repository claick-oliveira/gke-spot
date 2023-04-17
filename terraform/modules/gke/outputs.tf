// gke module
output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.endpoint
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "location" {
  value = module.gke.location
}

output "master_kubernetes_version" {
  description = "Kubernetes version of the master"
  value       = module.gke.master_version
}

output "ca_certificate" {
  description = "The cluster ca certificate (base64 encoded)"
  value       = module.gke.ca_certificate
}

output "client_token" {
  sensitive = true
  value     = base64encode(data.google_client_config.default.access_token)
}

output "cluster_id" {
  description = "Cluster ID"
  value       = module.gke.cluster_id
}

output "service_account" {
  description = "The service account to default running nodes as if not overridden in `node_pools`."
  value       = google_service_account.gke-spot-sa.email
}
