variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the KMS key ring — regional keys never leave this geography"
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

variable "storage_sa_email" {
  description = "Email of the storage service account granted encrypt/decrypt access"
  type        = string
}
