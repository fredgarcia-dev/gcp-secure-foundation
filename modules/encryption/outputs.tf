output "key_ring_id" {
  description = "The ID of the KMS key ring"
  value       = google_kms_key_ring.keyring.id
}

output "crypto_key_id" {
  description = "The ID of the crypto key (used by storage and audit modules)"
  value       = google_kms_crypto_key.key.id
}

output "crypto_key_name" {
  description = "The name of the crypto key"
  value       = google_kms_crypto_key.key.name
}
