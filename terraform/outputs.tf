output "vpc_name" {
  description = "The name of the VPC"
  value       = module.vpc.vpc_name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.vpc.subnet_name
}

output "subnet_proxy_name" {
  description = "The name of the proxy subnet"
  value       = module.vpc.subnet_proxy_name
}

output "repository_name" {
  description = "The name of the Artifact Registry Repository"
  value       = module.artifactregistry.repository_name
}

output "repository_id" {
  description = "The ID of the Artifact Registry Repository"
  value       = module.artifactregistry.repository_id
}

output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.kubernetes_endpoint
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.cluster_name
}

output "location" {
  value = module.gke.location
}

output "master_kubernetes_version" {
  description = "Kubernetes version of the master"
  value       = module.gke.master_kubernetes_version
}

output "ca_certificate" {
  sensitive   = true
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
  value       = module.gke.service_account
}
