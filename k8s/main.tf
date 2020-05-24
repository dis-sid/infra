terraform {
    backend "gcs" {
        bucket = "dissid-infra-2020"
        prefix = "k8s_state"
    }
}

provider "google" {
    version = "3.15.0"
    project = "dataplumber"
    region = "europe-west1"
    zone = "europe-west1-c"
}

resource "google_container_cluster" "k8s_cluster" {
    name = "dissid-k8s"
    description = "general purpose cluster"
    location = "europe-west1-c"
    remove_default_node_pool = true
    initial_node_count = 1
    master_auth {
        username = var.k8s_master_user
        password = var.k8s_master_pw
        client_certificate_config {
            issue_client_certificate = true
        }
    }
}

resource "google_service_account" "k8s_node_sa" {
    account_id   = "k8s-node"
    display_name = "k8s-node"
    description = "k8s node service account"
}

resource "google_project_iam_member" "node_log_role" {
    role    = "roles/logging.logWriter"
    member  = "serviceAccount:${google_service_account.k8s_node_sa.email}"
}

resource "google_project_iam_member" "node_monitoring_role" {
    role    = "roles/monitoring.metricWriter"
    member  = "serviceAccount:${google_service_account.k8s_node_sa.email}"
}

resource "google_container_node_pool" "small_preemptible_nodes" {
    name       = "small-preemp"
    location   = "europe-west1-c"
    cluster    = google_container_cluster.k8s_cluster.name
    node_count = 1

    node_config {
        preemptible  = true
        machine_type = "n1-standard-1"
        service_account = google_service_account.k8s_node_sa.email

        metadata = {
            disable-legacy-endpoints = "true"
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]
    }
}
