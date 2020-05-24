terraform {
    backend "gcs" {
        bucket = "dissid-infra-2020"
        prefix = "economy_state"
    }
}

provider "google" {
    version = "3.15.0"
    project = "dataplumber"
    region = "europe-west1"
    zone = "europe-west1-c"
}

resource google_storage_bucket "economy" {
    name = "dissid-economy-2020"
    location = "EU"
    force_destroy = true
}
