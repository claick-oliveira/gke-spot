variable "gcp_project_id" {
  description = "The ID of the GCP project ID where the project will be created"
  type = string
}

variable "gcp_region" {
  description = "The GCP region where the project will be created"
  type = string
}

variable "gcp_zone" {
  description = "The GCP availability zone where the project will be created"
  type = string
}

variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}
