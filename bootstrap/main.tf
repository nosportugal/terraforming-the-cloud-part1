## terraform & providers
terraform {
  required_version = ">= 1.5.7"
  backend "gcs" {
    bucket                      = "tto-workshops-lab-848993-terraform-state"
    prefix                      = "tf-state"
    impersonate_service_account = "terraform-sa-002@tto-workshops-lab-848993.iam.gserviceaccount.com"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.23"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.region
}

data "google_project" "this" {
  project_id = var.project_id
}

# services

## Enable services
locals {
  gcp_service_list = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

resource "google_project_service" "this" {
  for_each = toset(local.gcp_service_list)
  project  = data.google_project.this.project_id

  service                    = each.key
  disable_dependent_services = true
  disable_on_destroy         = true
}
