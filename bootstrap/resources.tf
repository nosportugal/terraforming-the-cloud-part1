# resources
resource "google_compute_network" "default" {
  name                    = "vpc-default"
  auto_create_subnetworks = false

  depends_on = [
    google_project_iam_member.this
  ]
}

resource "google_compute_subnetwork" "default" {
  name          = "subnetwork-default"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.default.id
}

resource "google_compute_firewall" "default" {
  name     = "fw-ingressfromiap-p-01"
  network  = google_compute_network.default.name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["allow-iap"]
}