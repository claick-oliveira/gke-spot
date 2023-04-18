// gke module
data "google_client_config" "default" {}

resource "google_service_account" "gke-spot-sa" {
  account_id   = "tf-gke-spot-sa"
  display_name = "Service Account For GKE ${var.cluster_name}"
  project      = var.gcp_project_id
}
resource "google_project_iam_member" "artifactregistry-role" {
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke-spot-sa.email}"
  project = var.gcp_project_id
}

resource "google_project_iam_member" "node-service-account-role" {
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke-spot-sa.email}"
  project = var.gcp_project_id
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.gcp_project_id
  name                       = var.cluster_name
  region                     = var.gcp_region
  regional                   = false
  zones                      = var.gcp_zones
  network                    = var.vpc_name
  subnetwork                 = var.subnet_name
  ip_range_pods              = var.cidr_pods
  ip_range_services          = var.cidr_services
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_cost_allocation     = true
  gateway_api_channel        = var.gateway_api_channel
  create_service_account     = false
  release_channel            = "REGULAR"
  remove_default_node_pool   = true

  node_pools = [
    {
      name                   = "ondemand-node-pool"
      machine_type           = var.machine_type
      node_locations         = var.node_locations
      min_count              = 0
      max_count              = 0
      total_min_count        = var.min_count
      total_max_count        = var.max_count
      local_ssd_count        = 0
      spot                   = false
      disk_size_gb           = 100
      disk_type              = "pd-standard"
      image_type             = "COS_CONTAINERD"
      enable_gcfs            = false
      enable_gvnic           = false
      auto_repair            = true
      auto_upgrade           = true
      preemptible            = false
      initial_node_count     = 1
      service_account        = "tf-gke-spot-sa@${var.gcp_project_id}.iam.gserviceaccount.com"
      location_policy        = "BALANCED"
    },
    {
      name                   = "spot-node-pool"
      machine_type           = var.machine_type
      node_locations         = var.node_locations
      min_count              = 0
      max_count              = 0
      total_min_count        = var.min_count
      total_max_count        = var.max_count
      local_ssd_count        = 0
      spot                   = true
      disk_size_gb           = 100
      disk_type              = "pd-standard"
      image_type             = "COS_CONTAINERD"
      enable_gcfs            = false
      enable_gvnic           = false
      auto_repair            = true
      auto_upgrade           = true
      preemptible            = false
      initial_node_count     = 1
      service_account        = "tf-gke-spot-sa@${var.gcp_project_id}.iam.gserviceaccount.com"
      location_policy        = "ANY"
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  node_pools_taints = {
    all = []

    ondemand-node-pool = [
      {
        key    = "ondemand-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]

    spot-node-pool = [
      {
        key    = "spot-node-pool"
        value  = true
        effect = "NO_SCHEDULE"
      },
    ]
  }

}
