terraform {
  backend "gcs" {
    bucket  = "fred-sre-portfolio-terraform-state"
    prefix  = "gcp-secure-foundation/state"
  }
}
