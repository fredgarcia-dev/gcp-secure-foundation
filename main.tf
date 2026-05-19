module "networking" {
  source           = "./modules/networking"
  project_id       = var.project_id
  region           = var.region
  secondary_region = var.secondary_region
  name_prefix      = local.name_prefix
  labels           = local.common_labels
}

module "iam" {
  source      = "./modules/iam"
  project_id  = var.project_id
  name_prefix = local.name_prefix
  labels      = local.common_labels
}

module "encryption" {
  source           = "./modules/encryption"
  project_id       = var.project_id
  region           = var.region
  name_prefix      = local.name_prefix
  labels           = local.common_labels
  storage_sa_email = module.iam.storage_sa_email
}

module "storage" {
  source           = "./modules/storage"
  project_id       = var.project_id
  region           = var.region
  name_prefix      = local.name_prefix
  labels           = local.common_labels
  crypto_key_id    = module.encryption.crypto_key_id
  storage_sa_email = module.iam.storage_sa_email
}

module "audit" {
  source        = "./modules/audit"
  project_id    = var.project_id
  region        = var.region
  name_prefix   = local.name_prefix
  labels        = local.common_labels
  crypto_key_id = module.encryption.crypto_key_id
}
