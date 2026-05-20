# GCP Secure Foundation

A production-grade GCP baseline provisioned with Terraform, demonstrating
modular architecture, remote state, least-privilege IAM, customer-managed
encryption, private networking, and FedRAMP-aligned audit logging.

---

## What This Builds

| Security Domain | Resources |
|---|---|
| Networking | Custom VPC, 2 private subnets, Cloud NAT, firewall rules |
| IAM | 3 least-privilege service accounts, 4 org policy constraints |
| Encryption | Cloud KMS key ring + key, 90-day rotation |
| Storage | Private GCS bucket, CMEK, versioning, 365-day retention |
| Audit Logging | Project audit config, BigQuery export, 365-day retention |

No public IP addresses. No service account keys. No default network.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GCP PROJECT                                   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  VPC NETWORK — {env}-secure-vpc                          │   │
│  │                                                           │   │
│  │  ┌──────────────────┐    ┌──────────────────┐           │   │
│  │  │  Private Subnet   │    │  Private Subnet   │           │   │
│  │  │  us-central1      │    │  us-east1         │           │   │
│  │  │  10.0.1.0/24      │    │  10.0.2.0/24      │           │   │
│  │  └────────┬─────────┘    └──────────┬────────┘           │   │
│  │           │                          │                     │   │
│  │  ┌────────▼──────────────────────────▼────┐              │   │
│  │  │  Cloud Router + Cloud NAT               │              │   │
│  │  │  egress-only — internet cannot reach in │              │   │
│  │  └────────────────────────────────────────┘              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Cloud KMS   │  │  GCS Bucket  │  │  Cloud Audit Logs    │  │
│  │  90-day key  │  │  CMEK + 365d │  │  → BigQuery 365d     │  │
│  │  rotation    │  │  versioning  │  │  partitioned tables  │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  IAM — Least Privilege Service Accounts                   │   │
│  │  compute-sa  roles/compute.instanceAdmin.v1              │   │
│  │  storage-sa  roles/storage.objectViewer                  │   │
│  │  logging-sa  roles/logging.logWriter                     │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### 1. GCP Account and SDK

```bash
# Install gcloud CLI
brew install --cask google-cloud-sdk

# Authenticate
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 2. Terraform

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version  # should be >= 1.7.0
```

### 3. Remote State Bucket

Create the GCS bucket Terraform will use to store state:

```bash
gcloud storage buckets create gs://YOUR_PROJECT_ID-terraform-state \
  --location=us-central1 \
  --uniform-bucket-level-access

gcloud storage buckets update gs://YOUR_PROJECT_ID-terraform-state \
  --versioning
```

Then update `backend.tf` with your bucket name.

---

## Deploy

```bash
# 1. Set your project ID in the environment file
#    Edit envs/dev.tfvars — replace "your-project-id"

# 2. Initialize — downloads providers, configures GCS backend
terraform init

# 3. Validate configuration
terraform validate

# 4. Format check
terraform fmt -recursive

# 5. Preview changes — no infrastructure created yet
terraform plan -var-file=envs/dev.tfvars

# 6. Apply — creates all infrastructure
terraform apply -var-file=envs/dev.tfvars

# 7. Destroy when done (avoids any costs)
terraform destroy -var-file=envs/dev.tfvars
```

## Deploy to a Different Environment

```bash
# Production
terraform plan -var-file=envs/prod.tfvars
terraform apply -var-file=envs/prod.tfvars
```

Each environment gets independently named resources via the `environment`
variable — `dev-secure-vpc`, `prod-secure-vpc`, etc.

---

## Modules

| Module | Path | Purpose |
|---|---|---|
| networking | `modules/networking` | Custom VPC, private subnets, Cloud NAT, firewall rules |
| iam | `modules/iam` | Service accounts, IAM bindings, org policy constraints |
| encryption | `modules/encryption` | KMS key ring, crypto key, 90-day rotation |
| storage | `modules/storage` | GCS bucket with CMEK, versioning, retention policy |
| audit | `modules/audit` | Audit log config, BigQuery export, log sink |

Each module exposes typed outputs consumed by downstream modules.
The root `main.tf` wires them together — no module imports another directly.

---

## Key Design Decisions

See [ARCHITECTURE.md](./ARCHITECTURE.md) for full ADRs. Summary:

- **Custom VPC** — no default network, no auto-created subnets, no inherited firewall rules
- **No service account keys** — org policy enforces this; no key files exist anywhere
- **Customer-managed KMS** — 90-day rotation, instant revocation capability, regional key ring
- **Regional resources** — data residency enforced at the resource level, not just policy
- **BigQuery audit export** — 365-day retention satisfies FedRAMP; SQL-queryable without extra tooling


*Fred Garcia — Principal Solutions Architect*
*Built with Terraform 1.7+ and Google Provider 5.x*
