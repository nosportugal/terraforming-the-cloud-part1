# data "google_compute_network" "default" {
#   name = "nos-vpc-01"
# }

data "google_compute_subnetwork" "default" {
  name    = "default"
  region  = "europe-west1"
}
