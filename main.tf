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
#credentials = "C:\\Users\\RASUVARN\\Downloads\\terraform-actions-0483c773b5e6.json"
}

resource "google_storage_bucket" "bucket" {
name = "terraform-action-testbucket-1"
location = "us-central1"
}