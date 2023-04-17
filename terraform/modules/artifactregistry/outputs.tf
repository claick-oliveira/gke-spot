// artifactregistry module
output "repository_name" {
  description = "The name of the Artifact Registry Repository"
  value       = google_artifact_registry_repository.artifactregistry.name
}

output "repository_id" {
  description = "The ID of the Artifact Registry Repository"
  value       = google_artifact_registry_repository.artifactregistry.id
}
