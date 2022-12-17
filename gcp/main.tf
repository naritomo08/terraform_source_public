provider "google" {
  credentials = file("gcp.json")
  project     = "<プロジェクトID>"
  region      = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

# ftstateをバケットに保管する。
terraform {
  #backend "gcs" {
  #  credentials = "gcp.json"
  #  bucket  = "<バケット名>"
  #}
}

resource "google_compute_network" "vpc_network" {
  name = "gcpvpc"
}
