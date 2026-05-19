variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the GCS bucket — enforces data residency"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "crypto_key_id" {
  description = "KMS crypto key ID for customer-managed encryption"
  type        = string
}

variable "storage_sa_email" {
  description = "Email of the storage service account granted objectViewer access"
  type        = string
}
