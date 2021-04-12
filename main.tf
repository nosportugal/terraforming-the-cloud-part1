
## terraform & providers
terraform {
  required_version = ">= 0.14.0"
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.64.0"
    }
  }
}

## variaveis locais
locals {
  prefix = var.prefix
}


## referenciar um recurso já existente
## ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project
data "google_project" "this" {
  project_id = var.project_id
}

## local resources
resource "random_pet" "this" {
  length = 2
  prefix = local.prefix
  separator = "-"
}

## remote resources
## google_service_account doc: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "default" {
  account_id = "${random_pet.this.id}-sa-1"
  display_name = "${random_pet.this.id} pet"
  project = data.google_project.this.project_id
}