locals {
  # Consistent naming convention across all resources
  # Format: {environment}-{resource_type}-{descriptor}
  name_prefix = "${var.environment}-secure"

  # Common labels applied to all resources
  common_labels = {
    environment    = var.environment
    project        = var.project_id
    managed_by     = "terraform"
    security_level = "high"
    owner          = "fred-garcia-sre"
  }
}
