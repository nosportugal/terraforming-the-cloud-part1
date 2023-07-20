
## 3.2 Descomentar apenas quando for pedido
#resource "google_compute_network" "imported" {
#  name                    = "${random_pet.this.id}-vpc"
#  auto_create_subnetworks = false
#}

## 3.2 Descomentar apenas quando for pedido
#resource "google_compute_subnetwork" "imported" {
#  name          = "${random_pet.this.id}-subnet"
#  region        = var.region
#  ip_cidr_range = "10.0.0.0/9"
#  network       = google_compute_network.imported.id
#
#  log_config { # This is required due to an organization policy
#    aggregation_interval = "INTERVAL_10_MIN"
#    flow_sampling        = 0.3
#    metadata             = "EXCLUDE_ALL_METADATA"
#  }
#
#}

## 3.3 Descomentar apenas quando for pedido
# resource "google_compute_firewall" "imported_iap" {
#  name    = "${random_pet.this.id}-fw-iap"
#  network = google_compute_network.imported.name
#  description = "Allow Ingress From iap for SSH and RDP"
#  source_ranges = ["35.235.240.0/20"]
#
#  allow {
#    protocol = "tcp"
#    ports    = ["22", "3389"]
#  }
#  target_tags = ["allow-iap"]
# }
#
# resource "google_compute_instance" "vm2" {
#  name         = "${random_pet.this.id}-vm2"
#  machine_type = "g1-small"
#  zone         = "${var.region}-b"
#  tags = [ "allow-iap" ]
#
#  boot_disk {
#    initialize_params {
#      image = "debian-cloud/debian-11"
#    }
#  }
#
#  network_interface {
#    subnetwork = google_compute_subnetwork.imported.self_link
#  }
#
#  # se virem isto, avisem-me que eu explico porque 😎
#  depends_on = [
#    google_compute_firewall.imported_iap
#  ]
# }
#
# output "vm2" {
#  value = {
#    vm_name = google_compute_instance.vm2.name
#    gcloud_cmd = "gcloud compute ssh ${google_compute_instance.vm2.name} --project=${google_compute_instance.vm2.project} --zone ${google_compute_instance.vm2.zone}"
#  }
# }
