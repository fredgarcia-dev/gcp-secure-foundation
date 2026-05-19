output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_primary_id" {
  description = "The ID of the primary subnet (us-central1)"
  value       = google_compute_subnetwork.primary.id
}

output "subnet_secondary_id" {
  description = "The ID of the secondary subnet (us-east1)"
  value       = google_compute_subnetwork.secondary.id
}

output "router_id" {
  description = "The ID of the Cloud Router (used by other modules)"
  value       = google_compute_router.router.id
}
