data "google_storage_project_service_account" "gcs_sa" {
  project = var.project_id
}

resource "google_kms_crypto_key_iam_member" "gcs_encrypter_decrypter" {
  crypto_key_id = var.crypto_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
}

resource "google_storage_bucket" "data" {
  name                        = "${var.name_prefix}-data-${var.project_id}"
  location                    = var.region
  storage_class               = "STANDARD"
  project                     = var.project_id
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = var.labels

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = var.crypto_key_id
  }

  retention_policy {
    retention_period = 31536000
    is_locked        = false
  }

  depends_on = [google_kms_crypto_key_iam_member.gcs_encrypter_decrypter]

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_binding" "storage_sa_viewer" {
  bucket = google_storage_bucket.data.name
  role   = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${var.storage_sa_email}",
  ]
}
