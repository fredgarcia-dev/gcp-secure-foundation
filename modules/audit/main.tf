# Enable data access audit logs for all services — captures every API call
resource "google_project_iam_audit_config" "all_services" {
  project = var.project_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

# BigQuery service agent needs KMS access to encrypt/decrypt audit data
data "google_bigquery_default_service_account" "bq_sa" {
  project = var.project_id
}

resource "google_kms_crypto_key_iam_member" "bq_encrypter_decrypter" {
  crypto_key_id = var.crypto_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_bigquery_default_service_account.bq_sa.email}"
}

# BigQuery dataset for long-term audit log storage
resource "google_bigquery_dataset" "audit_logs" {
  dataset_id                  = "${replace(var.name_prefix, "-", "_")}_audit_logs"
  friendly_name               = "Audit Logs"
  description                 = "Long-term storage for project audit logs — 365-day retention"
  location                    = var.region
  project                     = var.project_id
  default_table_expiration_ms = 31536000000
  labels                      = var.labels

  default_encryption_configuration {
    kms_key_name = var.crypto_key_id
  }

  depends_on = [google_kms_crypto_key_iam_member.bq_encrypter_decrypter]
}

# Export all project logs to BigQuery — no filter, capture everything
resource "google_logging_project_sink" "audit" {
  name                   = "${var.name_prefix}-audit-sink"
  project                = var.project_id
  destination            = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.audit_logs.dataset_id}"
  filter                 = ""
  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }
}

# Grant the sink's writer identity editor access to write log tables
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.audit_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.audit.writer_identity
}
