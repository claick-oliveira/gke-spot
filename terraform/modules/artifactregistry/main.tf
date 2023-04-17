// gke module
data "google_client_config" "default" {}

resource "google_artifact_registry_repository" "artifactregistry" {
  location      = var.gcp_region
  repository_id = var.repository_id
  description   = "Repository for ${var.repository_id} service"
  format        = "DOCKER"
}
