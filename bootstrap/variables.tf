variable "project_id" {
  description = "The project id to bootstrap resources."
  type        = string
}

variable "region" {
  description = "The default region to create resources."
  type        = string
  default     = "europe-west1"
}

variable "gcp_trainer_group" {
  description = "The group of the trainers for IAM purposes."
  type        = string
}
