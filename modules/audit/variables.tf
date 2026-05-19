variable "project_id" {
  description = "GCP project ID"
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
  description = "KMS crypto key ID for BigQuery dataset encryption"
  type        = string
}

variable "region" {
  description = "Region for BigQuery dataset — must match KMS key region"
  type        = string
}
