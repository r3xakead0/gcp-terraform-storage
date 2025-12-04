output "bucket_url" {
  description = "Bucket URL"
  value       = google_storage_bucket.my_first_bucket.url
}

output "bucket_name" {
  description = "Bucket name"
  value       = google_storage_bucket.my_first_bucket.name
}
