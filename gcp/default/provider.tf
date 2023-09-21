provider "google" {
  credentials = file("../gcp.json")
  project     = "api-project-274993796561"
  region      = "asia-northeast1"
  zone        = "asia-northeast1-a"
}
