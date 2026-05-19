# --- Compute Service Account ---
resource "google_service_account" "compute" {
  account_id   = "${var.name_prefix}-compute-sa"
  display_name = "Compute Service Account"
  description  = "Least-privilege SA for compute resources — instanceAdmin only"
  project      = var.project_id
}

resource "google_project_iam_member" "compute_sa_role" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.compute.email}"
}

# --- Storage Service Account ---
resource "google_service_account" "storage" {
  account_id   = "${var.name_prefix}-storage-sa"
  display_name = "Storage Service Account"
  description  = "Least-privilege SA for GCS access — objectViewer read-only"
  project      = var.project_id
}

resource "google_project_iam_member" "storage_sa_role" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.storage.email}"
}

# --- Logging Service Account ---
resource "google_service_account" "logging" {
  account_id   = "${var.name_prefix}-logging-sa"
  display_name = "Logging Service Account"
  description  = "Least-privilege SA for audit logging — logWriter write-only"
  project      = var.project_id
}

resource "google_project_iam_member" "logging_sa_role" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.logging.email}"
}

# --- Organization Policies (project-level, requires GCP Organization) ---
# These enforce preventive controls. Requires roles/orgpolicy.policyAdmin
# on the project. If running a standalone billing account without an org,
# comment these out — the SAs and IAM bindings above still apply.

# Org policies below require a GCP Organization — not available on personal
# free-tier accounts. Uncomment when deploying to an org-backed project.

# resource "google_org_policy_policy" "require_shielded_vm" {
#   name   = "projects/${var.project_id}/policies/compute.requireShieldedVm"
#   parent = "projects/${var.project_id}"
#   spec { rules { enforce = "TRUE" } }
# }

# resource "google_org_policy_policy" "skip_default_network" {
#   name   = "projects/${var.project_id}/policies/compute.skipDefaultNetworkCreation"
#   parent = "projects/${var.project_id}"
#   spec { rules { enforce = "TRUE" } }
# }

# resource "google_org_policy_policy" "uniform_bucket_access" {
#   name   = "projects/${var.project_id}/policies/storage.uniformBucketLevelAccess"
#   parent = "projects/${var.project_id}"
#   spec { rules { enforce = "TRUE" } }
# }

# resource "google_org_policy_policy" "disable_sa_key_creation" {
#   name   = "projects/${var.project_id}/policies/iam.disableServiceAccountKeyCreation"
#   parent = "projects/${var.project_id}"
#   spec { rules { enforce = "TRUE" } }
# }
