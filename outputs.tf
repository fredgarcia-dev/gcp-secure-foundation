# Networking
output "vpc_id" {
  description = "The ID of the VPC network"
  value       = module.networking.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = module.networking.vpc_name
}

output "subnet_primary_id" {
  description = "The ID of the primary subnet (us-central1)"
  value       = module.networking.subnet_primary_id
}

output "subnet_secondary_id" {
  description = "The ID of the secondary subnet (us-east1)"
  value       = module.networking.subnet_secondary_id
}

# IAM — Service Account Emails
output "compute_sa_email" {
  description = "Email of the compute service account"
  value       = module.iam.compute_sa_email
}

output "storage_sa_email" {
  description = "Email of the storage service account"
  value       = module.iam.storage_sa_email
}

output "logging_sa_email" {
  description = "Email of the logging service account"
  value       = module.iam.logging_sa_email
}

# Encryption
output "kms_key_name" {
  description = "The name of the KMS crypto key"
  value       = module.encryption.crypto_key_name
}

# Storage
output "bucket_name" {
  description = "The name of the secure GCS data bucket"
  value       = module.storage.bucket_name
}

output "bucket_url" {
  description = "The gs:// URL of the secure GCS data bucket"
  value       = module.storage.bucket_url
}

# Audit
output "bigquery_dataset_id" {
  description = "The BigQuery dataset ID for audit logs"
  value       = module.audit.bigquery_dataset_id
}

output "audit_sink_name" {
  description = "The name of the audit log sink"
  value       = module.audit.sink_name
}
