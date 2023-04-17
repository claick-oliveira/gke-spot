// vpc module
variable "vpc_name" {
  description = "The name of the VPC to create"
  type        = string
}

variable "subnet_name" {
  description = "The name of the Subnet to create"
  type        = string
}

variable "subnet_name_proxy" {
  description = "The name of the Proxy Subnet to create"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region"
  type = string
}

variable "cidr_range" {
  description = "The Subnet's CIDR range"
  type = string
}

variable "cidr_range_proxy" {
  description = "The Subnet's CIDR range for proxy"
  type = string
}

variable "cidr_pods" {
  description = "TThe Secondary CIDR range for pods"
  type = string
}

variable "cidr_services" {
  description = "TThe Secondary CIDR range for services"
  type = string
}
