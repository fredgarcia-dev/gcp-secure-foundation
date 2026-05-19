output "compute_sa_email" {
  description = "Email of the compute service account"
  value       = google_service_account.compute.email
}

output "storage_sa_email" {
  description = "Email of the storage service account"
  value       = google_service_account.storage.email
}

output "logging_sa_email" {
  description = "Email of the logging service account"
  value       = google_service_account.logging.email
}
