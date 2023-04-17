// gke module
variable "cluster_name" {
  description = "The name of the Cluster to create"
  type        = string
}

variable "subnet_name" {
  description = "The name of the Subnet to create"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type = string
}

variable "gcp_region" {
  description = "The GCP region"
  type = string
}

variable "gcp_zones" {
  description = "The GCP zones"
  type = list
}

variable "vpc_name" {
  description = "The name of the VPC where the cluster will be created"
  type        = string
}

variable "cidr_pods" {
  description = "The Secondary CIDR range for pods"
  type = string
}

variable "cidr_services" {
  description = "The Secondary CIDR range for services"
  type = string
}

variable "machine_type" {
  description = "The machine type for Nodes"
  type = string
}

variable "node_locations" {
  description = "The node locations"
  type = string
}

variable "min_count" {
  description = "The node min count"
  type = string
}

variable "max_count" {
  description = "The node max count"
  type = string
}

variable "gateway_api_channel" {
  type        = string
  description = "The gateway api channel of this cluster. Accepted values are `CHANNEL_STANDARD` and `CHANNEL_DISABLED`."
  default     = null
}
