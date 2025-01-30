provider "google" {
  project = "single-mix-449209-n7"
  region  = "us-central1"
}

terraform {
  backend "gcs" {
    bucket = "devops-dauphine-tp"
    prefix = "terraform/state"
  }
}
