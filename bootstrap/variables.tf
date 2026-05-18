variable "project_id" {
  description = "The project id to bootstrap resources."
  type        = string
  default     = "tto-workshops-lab-848993"
}

variable "region" {
  description = "The default region to create resources."
  type        = string
  default     = "europe-west1"
}

variable "gcp_trainer_group" {
  description = "The group of the trainers for IAM purposes."
  type        = string
  default     = "tfworkshop01@nos.pt"
}

variable "master_zone_dns_name" {
  description = "The DNS name of the master zone."
  type        = string
  default     = "terraforming.cg.tentwentyone.io"
}
