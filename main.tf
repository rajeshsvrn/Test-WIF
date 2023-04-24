/*
terraform {
required_providers {
google = {
source = "hashicorp/google"
version = "4.61.0"
        }
     }
}

provider "google" {
# Configuration options
project = terraform-actions
region = us-central1
# Mention the path of the Json file which is download while creating service account
credentials = "C:\\Users\\RASUVARN\\Downloads\\terraform-actions-0483c773b5e6.json"
}


resource "google_storage_bucket" "bucket" {
name = "terraform-action-testbucket-15"
location = "us-central1"
}

*/

locals {
  project_id = "terraform-test-384414"
  repo       = "rajeshsvrn/Test-WIF" 
}

resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = local.project_id
  workload_identity_pool_id = "github-pool2"
  display_name              = "GitHub pool"
  description               = "Identity pool for GitHub deployments"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider2"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}



resource "google_service_account" "github_actions" {
  project      = local.project_id
  account_id   = "github-actions"
  display_name = "Service Account used for GitHub Actions"
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${local.repo}"
}


output "workload_identity_provider" {
  value = "${google_iam_workload_identity_pool.github_pool.name}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
}

output "service_account" {
  value = google_service_account.github_actions.email
}



