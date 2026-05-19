output "bucket_name" {
  description = "The name of the secure data bucket"
  value       = google_storage_bucket.data.name
}

output "bucket_url" {
  description = "The gs:// URL of the secure data bucket"
  value       = google_storage_bucket.data.url
}

output "bucket_self_link" {
  description = "The self-link URI of the secure data bucket"
  value       = google_storage_bucket.data.self_link
}
