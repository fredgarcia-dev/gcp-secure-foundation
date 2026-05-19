# GCP Secure Foundation — Terraform Project
## Claude Code Build Plan
### Fred Garcia | Principal Solutions Architect Portfolio | May 2026

---

## Why This Project

This project demonstrates hands-on Terraform proficiency across core
concepts that every cloud employer — PAN, Stanford Health Care, NVIDIA,
and federal contractors — recognizes and values.

It provisions a production-grade secure GCP baseline using Terraform
best practices: modular architecture, remote state, least-privilege IAM,
encryption, network segmentation, and audit logging.

PAN runs on GCP. Stanford Health Care uses GCP for ML infrastructure.
NVIDIA lists GCP as a key cloud partner platform. One project — three
active opportunities strengthened simultaneously.

---

## What This Project Demonstrates

CORE TERRAFORM CONCEPTS:
- Modules — reusable, versioned, parameterized components
- Remote state — GCS backend with state locking (no local state files)
- Variables and outputs — clean parameterization and module interfaces
- Data sources — referencing existing GCP resources dynamically
- Locals — DRY configuration, avoid repetition
- Workspaces — separate dev/staging/prod environments
- Terraform plan and apply workflow — safe, reviewable changes
- .tfvars files — environment-specific configuration

SECURITY AND COMPLIANCE CONCEPTS:
- VPC network segmentation (Zero Trust pillar 3 — Networks)
- IAM least privilege (Zero Trust pillar 1 — Identity)
- KMS encryption at rest (Zero Trust pillar 5 — Data)
- Cloud Audit Logs (FedRAMP continuous monitoring requirement)
- VPC Service Controls (authorization boundary — FedRAMP analog)
- Private Google Access (data never traverses public internet)
- Org policies (preventive controls — no public IPs, enforce encryption)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    GCP PROJECT                                   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  VPC NETWORK — secure-vpc                                │   │
│  │                                                           │   │
│  │  ┌──────────────────┐    ┌──────────────────┐           │   │
│  │  │  Private Subnet   │    │  Private Subnet   │           │   │
│  │  │  us-central1      │    │  us-east1         │           │   │
│  │  │  10.0.1.0/24      │    │  10.0.2.0/24      │           │   │
│  │  └────────┬─────────┘    └──────────┬────────┘           │   │
│  │           │                          │                     │   │
│  │  ┌────────▼──────────────────────────▼────┐              │   │
│  │  │  Cloud Router + Cloud NAT               │              │   │
│  │  │  (private resources reach internet      │              │   │
│  │  │   — internet cannot reach them)         │              │   │
│  │  └────────────────────────────────────────┘              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Cloud KMS   │  │  GCS Bucket  │  │  Cloud Audit Logs    │  │
│  │  Key Ring    │  │  Encrypted   │  │  All services        │  │
│  │  + Key       │  │  Versioned   │  │  BigQuery export     │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  IAM — Least Privilege Service Accounts                   │   │
│  │  compute-sa: roles/compute.instanceAdmin (compute only)  │   │
│  │  storage-sa: roles/storage.objectViewer (read only)      │   │
│  │  logging-sa: roles/logging.logWriter (write logs only)   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  VPC Service Controls Perimeter                           │   │
│  │  Restricts: storage.googleapis.com, bigquery.googleapis  │   │
│  │  Only allowed from within VPC — no external API access   │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
gcp-secure-foundation/
├── README.md                    # Project overview and architecture
├── ARCHITECTURE.md              # ADRs for each design decision
├── .gitignore                   # Exclude .terraform, state files, secrets
├── .terraform-version           # Pin Terraform version (1.7.x)
├── backend.tf                   # GCS remote state configuration
├── main.tf                      # Root module — wires all modules together
├── variables.tf                 # Input variable declarations
├── outputs.tf                   # Output value declarations
├── locals.tf                    # Local values — naming conventions
├── providers.tf                 # Google provider configuration
├── terraform.tfvars.example     # Example variable values (no secrets)
├── envs/
│   ├── dev.tfvars               # Development environment values
│   └── prod.tfvars              # Production environment values
└── modules/
    ├── networking/              # VPC, subnets, Cloud NAT, firewall rules
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                     # Service accounts and IAM bindings
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── encryption/              # Cloud KMS key ring and keys
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── storage/                 # GCS bucket with encryption and versioning
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── audit/                   # Cloud Audit Logs and BigQuery export
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Prerequisites — Set Up Before Claude Code

### Task 0.1 — Create GCP Account (Free Tier)
Go to cloud.google.com — sign up for free tier
Google gives $300 credit for 90 days — more than enough for this project
No cost for VPC, IAM, KMS, or audit logging at this scale

### Task 0.2 — Install Google Cloud SDK
```bash
# Install gcloud CLI on Mac
brew install --cask google-cloud-sdk

# Authenticate
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### Task 0.3 — Install Terraform
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform version
```

### Task 0.4 — Create GCS Bucket for Remote State
```bash
# Create a bucket for Terraform state
# Must be globally unique — use your project ID
gsutil mb -l us-central1 gs://YOUR_PROJECT_ID-terraform-state

# Enable versioning so state history is preserved
gsutil versioning set on gs://YOUR_PROJECT_ID-terraform-state
```

### Task 0.5 — Create Project Folder
```bash
mkdir ~/projects/gcp-secure-foundation
cd ~/projects/gcp-secure-foundation
git init
```

---

## Phase 1 — Project Foundation

### Task 1.1 — Create .terraform-version
Pin to a specific version:
```
1.7.5
```

### Task 1.2 — Create providers.tf
```hcl
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
```

### Task 1.3 — Create backend.tf
```hcl
terraform {
  backend "gcs" {
    bucket  = "YOUR_PROJECT_ID-terraform-state"
    prefix  = "gcp-secure-foundation/state"
  }
}
```

### Task 1.4 — Create variables.tf
```hcl
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "secondary_region" {
  description = "Secondary GCP region for redundancy"
  type        = string
  default     = "us-east1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access private resources"
  type        = list(string)
  default     = []
}
```

### Task 1.5 — Create locals.tf
```hcl
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
```

### Task 1.6 — Create .gitignore
```
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfstate.lock.info
.terraform.lock.hcl
terraform.tfvars
*.auto.tfvars

# Secrets
*.json
credentials/
secrets/

# OS
.DS_Store
```

---

## Phase 2 — Networking Module

### Task 2.1 — Create modules/networking/main.tf

Build a VPC with:

RESOURCES TO CREATE:
1. google_compute_network — VPC network (custom mode, not auto)
2. google_compute_subnetwork — Private subnet us-central1 (10.0.1.0/24)
   - Enable private_ip_google_access (reach Google APIs without public IP)
   - Enable flow logs for network visibility
3. google_compute_subnetwork — Private subnet us-east1 (10.0.2.0/24)
   - Same configuration as us-central1
4. google_compute_router — Cloud Router for NAT (us-central1)
5. google_compute_router_nat — Cloud NAT (allows private resources
   to reach internet for updates — internet cannot reach them)
6. google_compute_firewall — Allow internal traffic (within VPC only)
7. google_compute_firewall — Deny all ingress from internet
8. google_compute_firewall — Allow egress to Google APIs only

KEY DESIGN DECISION:
No public IP addresses on any resource. All egress through Cloud NAT.
This enforces the Zero Trust principle of no implicit trust based on
network location — every resource is private by default.

### Task 2.2 — Create modules/networking/variables.tf
Variables: project_id, region, secondary_region, name_prefix, labels

### Task 2.3 — Create modules/networking/outputs.tf
Outputs: vpc_id, vpc_name, subnet_primary_id, subnet_secondary_id,
         router_id (needed by other modules)

---

## Phase 3 — IAM Module

### Task 3.1 — Create modules/iam/main.tf

Build least-privilege service accounts:

SERVICE ACCOUNT 1 — Compute Service Account
- Name: {name_prefix}-compute-sa
- Role: roles/compute.instanceAdmin.v1 (scoped to project only)
- Purpose: For any compute resources that need GCP API access
- NO roles/editor, NO roles/owner, NO roles/viewer (too broad)

SERVICE ACCOUNT 2 — Storage Service Account
- Name: {name_prefix}-storage-sa
- Role: roles/storage.objectViewer (read only)
- Purpose: Read-only access to GCS bucket
- Separate from compute — principle of separation of duties

SERVICE ACCOUNT 3 — Logging Service Account
- Name: {name_prefix}-logging-sa
- Role: roles/logging.logWriter (write logs only)
- Purpose: Applications write audit logs — cannot read or delete

ORGANIZATION POLICY (if org available, otherwise project policy):
- constraints/compute.requireShieldedVm — all VMs must use Shielded VM
- constraints/compute.skipDefaultNetworkCreation — no default network
- constraints/storage.uniformBucketLevelAccess — enforce uniform IAM
- constraints/iam.disableServiceAccountKeyCreation — no key files

KEY DESIGN DECISION:
No service account keys created anywhere. All authentication via
Workload Identity or application default credentials. Service account
keys are the most common source of GCP credential leaks.

### Task 3.2 — modules/iam/variables.tf
Variables: project_id, name_prefix, labels

### Task 3.3 — modules/iam/outputs.tf
Outputs: compute_sa_email, storage_sa_email, logging_sa_email

---

## Phase 4 — Encryption Module

### Task 4.1 — Create modules/encryption/main.tf

Build Cloud KMS key infrastructure:

RESOURCES:
1. google_kms_key_ring — Key ring in us-central1
   - Name: {name_prefix}-keyring
   - Location: us-central1 (regional — not global)

2. google_kms_crypto_key — Encryption key
   - Name: {name_prefix}-key
   - Rotation period: 7776000s (90 days — FedRAMP recommendation)
   - Purpose: ENCRYPT_DECRYPT
   - Protection level: SOFTWARE (HSM for production/regulated)

3. google_kms_crypto_key_iam_binding — Allow storage SA to use key
   - Role: roles/cloudkms.cryptoKeyEncrypterDecrypter
   - Member: Storage service account only

KEY DESIGN DECISION:
90-day key rotation is aligned to FedRAMP continuous monitoring
requirements. The key is regional (not global) to ensure data
never leaves the authorized geographic boundary — critical for
federal and healthcare compliance contexts.

### Task 4.2 — modules/encryption/variables.tf
Variables: project_id, region, name_prefix, labels, storage_sa_email

### Task 4.3 — modules/encryption/outputs.tf
Outputs: key_ring_id, crypto_key_id, crypto_key_name

---

## Phase 5 — Storage Module

### Task 5.1 — Create modules/storage/main.tf

Build secure GCS bucket:

RESOURCES:
1. google_storage_bucket — Secure data bucket
   - Location: US-CENTRAL1 (regional — data residency control)
   - Storage class: STANDARD
   - Uniform bucket level access: true (IAM only — no ACLs)
   - Versioning: enabled (recover deleted or overwritten objects)
   - Encryption: customer-managed key (KMS key from encryption module)
   - Public access prevention: enforced (block all public access)
   - Retention policy: 365 days minimum (compliance requirement)

2. google_storage_bucket_iam_binding — Grant storage SA read access
   - Role: roles/storage.objectViewer
   - Member: storage service account only

3. google_storage_bucket — Terraform state bucket (if not pre-created)

KEY DESIGN DECISION:
Public access prevention is set to enforced — not inherited. This
means even if an org policy is removed, the bucket remains private.
Defense in depth: multiple independent controls protecting the same
resource. Never rely on a single control.

### Task 5.2 — modules/storage/variables.tf
Variables: project_id, region, name_prefix, labels, crypto_key_id,
           storage_sa_email

### Task 5.3 — modules/storage/outputs.tf
Outputs: bucket_name, bucket_url, bucket_self_link

---

## Phase 6 — Audit Logging Module

### Task 6.1 — Create modules/audit/main.tf

Build comprehensive audit logging:

RESOURCES:
1. google_project_iam_audit_config — Enable audit logs for all services
   - Log types: ADMIN_READ, DATA_READ, DATA_WRITE for all services
   - This captures every API call made in the project

2. google_bigquery_dataset — Dataset for long-term log storage
   - Dataset ID: audit_logs
   - Location: US
   - Default table expiration: 365 days (1 year retention)
   - Encryption: customer-managed KMS key

3. google_logging_project_sink — Export logs to BigQuery
   - Destination: BigQuery dataset
   - Filter: All log entries (no filtering — capture everything)
   - Unique writer identity: true

4. google_bigquery_dataset_iam_member — Grant sink write access
   - Allow the logging sink service account to write to BigQuery

KEY DESIGN DECISION:
Exporting to BigQuery enables SQL queries against audit logs — you
can answer questions like "who accessed this bucket in the last 30
days" or "what API calls did this service account make this week"
without specialized tooling. This is the same pattern used in
FedRAMP continuous monitoring programs.

### Task 6.2 — modules/audit/variables.tf
Variables: project_id, name_prefix, labels, crypto_key_id

### Task 6.3 — modules/audit/outputs.tf
Outputs: sink_name, bigquery_dataset_id, audit_log_filter

---

## Phase 7 — Root Module

### Task 7.1 — Create main.tf (root module)

Wire all modules together:

```hcl
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
  name_prefix   = local.name_prefix
  labels        = local.common_labels
  crypto_key_id = module.encryption.crypto_key_id
}
```

### Task 7.2 — Create outputs.tf (root)
Expose key outputs:
- vpc_name, vpc_id
- subnet IDs
- service account emails
- KMS key name
- GCS bucket name
- BigQuery dataset ID

### Task 7.3 — Create environment tfvars files

envs/dev.tfvars:
```hcl
project_id       = "your-project-id"
region           = "us-central1"
secondary_region = "us-east1"
environment      = "dev"
```

envs/prod.tfvars:
```hcl
project_id       = "your-project-id"
region           = "us-central1"
secondary_region = "us-east1"
environment      = "prod"
```

---

## Phase 8 — Documentation and ADRs

### Task 8.1 — Create ARCHITECTURE.md with five ADRs

ADR-001: Why custom VPC over default network
Constraint: Default GCP network creates subnets in every region
with auto-assigned IP ranges — no control over segmentation
Decision: Custom mode VPC with manually defined subnets
Tradeoff: More configuration upfront for complete network control
Interview line: "Default networks are convenient for demos. They
are not acceptable in regulated environments."

ADR-002: Why no service account keys
Constraint: Service account key files are credentials that can be
exfiltrated and used indefinitely if not rotated
Decision: No key creation — all auth via application default credentials
Tradeoff: Slightly more complex local development setup for
elimination of the most common GCP credential leak vector
Interview line: "The most common GCP breach vector is leaked service
account keys. I removed the attack surface entirely."

ADR-003: Why customer-managed KMS keys over Google-managed
Constraint: In regulated environments key management must be
customer-controlled — you must be able to revoke access instantly
Decision: Cloud KMS with 90-day rotation aligned to FedRAMP guidance
Tradeoff: Operational overhead of key management for compliance
alignment and instant revocation capability
Interview line: "Google-managed keys are fine for most workloads.
When you need to revoke access in minutes — not days — you need
customer-managed keys."

ADR-004: Why regional resources over multi-region
Constraint: Data residency requirements in federal and healthcare
environments prohibit data from leaving defined geographic boundaries
Decision: All resources in us-central1 with us-east1 secondary
Tradeoff: Slightly higher latency for cross-region access for
guaranteed data residency compliance
Interview line: "Multi-region storage is convenient. It is also
a data residency violation in most federal contracts."

ADR-005: Why BigQuery for audit log export
Constraint: Cloud Logging retention defaults to 30 days — insufficient
for FedRAMP one-year audit log retention requirement
Decision: Export all logs to BigQuery with 365-day retention
Tradeoff: Storage cost for SQL-queryable audit trail that survives
beyond 30 days and satisfies federal retention requirements
Interview line: "Audit logs you cannot query are not useful. Audit
logs that expire in 30 days are not compliant."

### Task 8.2 — Create README.md
Sections:
- What this builds and why
- Architecture diagram (ASCII)
- Prerequisites
- How to deploy (terraform init, plan, apply)
- How to deploy to different environments (tfvars files)
- Module descriptions
- Key design decisions summary
- Interview talking points

---

## Deployment Workflow — How to Run It

Once built, this is the standard Terraform workflow:

```bash
cd ~/projects/gcp-secure-foundation

# Initialize — download providers, configure backend
terraform init

# Format code consistently
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan — see what will be created (no changes yet)
terraform plan -var-file=envs/dev.tfvars

# Apply — create the infrastructure
terraform apply -var-file=envs/dev.tfvars

# When done — destroy to avoid any costs
terraform destroy -var-file=envs/dev.tfvars
```

---

## Claude Code Launch Instructions

```bash
mkdir ~/projects/gcp-secure-foundation
cd ~/projects/gcp-secure-foundation
git init
cp ~/Downloads/GCP_TERRAFORM_BUILD_PLAN.md .
claude
```

Opening prompt for Claude Code:

"I want to build a GCP Secure Foundation Terraform project that
demonstrates production-grade IaC best practices including modular
architecture, remote state, least-privilege IAM, KMS encryption,
VPC network segmentation, and Cloud Audit Logging.

Read GCP_TERRAFORM_BUILD_PLAN.md and implement it phase by phase.

Start with Phase 1 — project foundation files (providers.tf,
backend.tf, variables.tf, locals.tf, .gitignore).

Then Phase 2 — the networking module.

Ask me before starting each new phase and show me the terraform
plan output before applying anything."

---

## Interview Talking Points — Memorize These

1. "I used a modular Terraform architecture — each security domain
   is its own module: networking, IAM, encryption, storage, and
   audit logging. Modules have defined interfaces through variables
   and outputs. The root module wires them together. This means I
   can upgrade the encryption module independently without touching
   the networking module."

2. "No service account keys exist anywhere in this project. The most
   common GCP breach vector is leaked service account key files. I
   removed the attack surface entirely by using application default
   credentials and Workload Identity instead."

3. "The KMS key rotates every 90 days — aligned to FedRAMP continuous
   monitoring guidance. That is not a coincidence. I designed the
   key rotation schedule to satisfy federal compliance requirements
   from the start rather than retrofitting it later."

4. "All audit logs export to BigQuery with 365-day retention. Cloud
   Logging defaults to 30 days — insufficient for FedRAMP one-year
   retention requirements. The BigQuery export is a compliance design
   decision, not an operational preference."

5. "The most important design decision in this project was putting
   all resources in a private network with no public IP addresses.
   Cloud NAT handles egress for software updates. The internet cannot
   reach any resource directly. That is Zero Trust network posture
   applied to GCP — not as a product, as an architecture."

---

## Connecting to Your PAN Interview

When the PAN technical interviewer asks about IaC say this:

"I built a GCP Secure Foundation Terraform project that provisions
a complete Zero Trust network baseline — private VPC with no public
IPs, least-privilege IAM with no service account keys, customer-
managed KMS encryption with 90-day rotation, and full audit logging
exported to BigQuery for one-year retention. Each security domain
is a separate module with clean interfaces. Remote state in GCS with
locking. Environment separation through tfvars files.

The design decisions map directly to FedRAMP and DoD compliance
requirements — data residency through regional resources, key
revocation through customer-managed KMS, audit retention through
BigQuery export. These are the same compliance constraints PAN's
federal customers operate under."

That answer — backed by real GitHub code — closes the Terraform
gap completely and connects directly to PAN's federal customer base.
