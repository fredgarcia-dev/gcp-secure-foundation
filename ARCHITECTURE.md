# Architecture Decision Records — GCP Secure Foundation

This document captures the five key design decisions made in this project,
the constraints that drove each decision, and the tradeoffs accepted.

---

## ADR-001: Custom VPC over Default Network

**Status:** Accepted

**Constraint:**
The GCP default network creates subnets in every region with auto-assigned
IP ranges. There is no control over segmentation, CIDR allocation, or which
regions are active. Default networks also enable inbound SSH and RDP from
the public internet via default firewall rules.

**Decision:**
Custom mode VPC (`auto_create_subnetworks = false`) with two manually defined
private subnets — `10.0.1.0/24` in `us-central1` and `10.0.2.0/24` in
`us-east1`. All firewall rules are explicitly defined. No rules are inherited.

**Tradeoff:**
More configuration upfront for complete control over network segmentation,
IP space, and traffic policy.

**Interview line:**
"Default networks are convenient for demos. They are not acceptable in
regulated environments."

---

## ADR-002: No Service Account Keys

**Status:** Accepted

**Constraint:**
Service account key files are long-lived credentials that can be exfiltrated
and used indefinitely if not rotated. They are the most common source of GCP
credential leaks — stored in repos, CI pipelines, and local machines.

**Decision:**
No `google_service_account_key` resources exist anywhere in this project.
Authentication uses application default credentials and Workload Identity.
The `iam.disableServiceAccountKeyCreation` org policy enforces this at the
policy layer, not just by convention.

**Tradeoff:**
Slightly more complex local development setup in exchange for eliminating
the most common GCP credential leak vector entirely.

**Interview line:**
"The most common GCP breach vector is leaked service account keys.
I removed the attack surface entirely."

---

## ADR-003: Customer-Managed KMS Keys over Google-Managed

**Status:** Accepted

**Constraint:**
In regulated environments, key management must be customer-controlled.
Google-managed keys do not allow instant revocation — if a key is
compromised or a contract ends, there is no way to immediately cut off
access to encrypted data.

**Decision:**
Cloud KMS with a 90-day (`7776000s`) rotation period aligned to FedRAMP
continuous monitoring guidance. Key ring is regional (`us-central1`) to
enforce data residency. `prevent_destroy = true` guards against accidental
key deletion that would make encrypted data permanently unrecoverable.

**Tradeoff:**
Operational overhead of key management and rotation in exchange for
compliance alignment and instant revocation capability.

**Interview line:**
"Google-managed keys are fine for most workloads. When you need to revoke
access in minutes — not days — you need customer-managed keys."

---

## ADR-004: Regional Resources over Multi-Region

**Status:** Accepted

**Constraint:**
Data residency requirements in federal and healthcare environments prohibit
data from leaving defined geographic boundaries. Multi-region GCS buckets
and global KMS keys replicate data across multiple regions without
explicit control over which regions are used.

**Decision:**
All resources provisioned in `us-central1` with `us-east1` as the secondary
region. KMS key ring is regional. GCS bucket is `US-CENTRAL1`. BigQuery
dataset is `US` (multi-region within the US boundary — acceptable for most
federal contracts).

**Tradeoff:**
Slightly higher latency for cross-region access in exchange for guaranteed
data residency compliance.

**Interview line:**
"Multi-region storage is convenient. It is also a data residency violation
in most federal contracts."

---

## ADR-005: BigQuery for Audit Log Export

**Status:** Accepted

**Constraint:**
Cloud Logging's default retention is 30 days. FedRAMP requires one year of
audit log retention. Logs you cannot query are not useful for incident
response — searching through raw log files at scale requires specialized
tooling.

**Decision:**
All project logs exported to a BigQuery dataset via a Cloud Logging sink
with no filter (captures everything). Dataset has a 365-day table expiration.
Partitioned tables reduce query cost. CMEK encryption applied to the dataset
using the same key ring as the rest of the project.

**Tradeoff:**
Storage cost for a SQL-queryable audit trail that satisfies federal retention
requirements and enables questions like "what API calls did this service
account make this week" without specialized tooling.

**Interview line:**
"Audit logs you cannot query are not useful. Audit logs that expire in
30 days are not compliant."
