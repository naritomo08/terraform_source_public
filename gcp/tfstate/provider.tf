provider "google" {
  credentials = file("../gcp.json")
  project     = "<プロジェクト名>"
  region      = "asia-northeast1"
  zone        = "asia-northeast1-a"
}

terraform {
  required_version = "= 1.2.4"
    required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.31.0"
    }
  }
}