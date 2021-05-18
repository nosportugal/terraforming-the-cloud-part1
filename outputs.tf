output "my_identifier" {
    value = random_pet.this.id
    description = "All my resources will be created using this prefix, so that I don't conflict with other's resources"
}

output "project_id" {
  value = data.google_project.this.name
}

output "region" {
  value = var.region
}

output "vm" {
  value = {
      vm_name = google_compute_instance.default.name
      vm_zone = google_compute_instance.default.zone
      vm_project = google_compute_instance.default.project
      vm_ip = google_compute_instance.default.network_interface.0.network_ip
      gcloud_cmd = "gcloud compute ssh ${google_compute_instance.default.name} --project=${google_compute_instance.default.project} --zone ${google_compute_instance.default.zone}"
  }
}

output "vm_name" {
  value = google_compute_instance.default.name
}

output "vm_zone" {
  value = google_compute_instance.default.zone
}

