
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

provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.region
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

## Recursos locais
resource "random_pet" "this" {
  length    = 2
  prefix    = local.prefix
  separator = "-"
}



#### Instância de VM e respetiva subnet

# referenciar a subnet já existente
data "google_compute_subnetwork" "default" {
  name    = "subnetwork-default"
  region  = "europe-west1"
}

# criar uma VM
resource "google_compute_instance" "default" {
  name         = "${random_pet.this.id}-vm"
  machine_type = "g1-small"
  zone         = "${var.region}-b"
  tags = [ "allow-iap" ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.default.self_link
  }
}
