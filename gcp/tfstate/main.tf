resource "google_storage_bucket" "terraform-state-store" {
    name     = "<バケット名>" #適当なユニークの名前に変えてください
    location = "asia-northeast1"
    storage_class = "REGIONAL"
    force_destroy = true

    versioning {
        enabled = true
    }

    lifecycle_rule {
        action {
        type = "Delete"
        }
        condition {
        num_newer_versions = 5
        }
    }
}
