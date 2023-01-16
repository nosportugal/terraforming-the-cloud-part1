variable "project_id" {
  type        = string
  description = "The google project identifier."
}

variable "region" {
  type        = string
  description = "The default region to use."
  default     = "europe-west1"
}

variable "prefix" {
  type        = string
  description = "A simple prefix"
  default     = "gcp"
}
