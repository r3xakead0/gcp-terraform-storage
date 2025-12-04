provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("~/terraform-key.json")
}

resource "google_storage_bucket" "mi_primer_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}