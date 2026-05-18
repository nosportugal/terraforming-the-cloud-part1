# iam
locals {

  iam_members = [
    {
      member = "group:${var.gcp_trainer_group}"
      roles = [
        "roles/compute.admin",
        "roles/compute.networkAdmin",
        "roles/dns.admin",
        "roles/iap.tunnelResourceAccessor",
        "roles/container.admin",
        "roles/iam.serviceAccountAdmin",
        "roles/iam.serviceAccountUser",
        "roles/serviceusage.serviceUsageAdmin"
      ]
    }
  ]

  iam_members_flattened = flatten([
    for key, item in local.iam_members : [
      for role_key, role in item.roles : {
        member = item.member
        role   = role
      }
    ]
  ])
}

resource "google_project_iam_member" "this" {
  for_each = { for iam_member in local.iam_members_flattened : "${iam_member.role}|${iam_member.member}" => iam_member }
  project  = var.project_id
  role     = each.value.role
  member   = each.value.member

  #Cloud Build creates the SA after enabling the API, so we need it to be enabled first
  depends_on = [
    google_project_service.this
  ]
}

resource "google_project_iam_member" "dns_admin_sa" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.dns_admin.email}"

  #Cloud Build creates the SA after enabling the API, so we need it to be enabled first
  depends_on = [
    google_project_service.this,
    google_project_iam_member.this
  ]
}

# resource "google_service_account_iam_member" "external_dns" {
#   service_account_id = google_service_account.dns_admin.name
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]"
# }
