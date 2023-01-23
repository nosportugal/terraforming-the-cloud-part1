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
  name        = "fw-ingressfromiap-p-01"
  description = "Allow Ingress From iap for SSH"
  network     = google_compute_network.default.name
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["allow-iap"]
  source_ranges = ["35.235.240.0/20"]
}
