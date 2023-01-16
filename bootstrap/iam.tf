# iam
locals {

  iam_members = [
    {
      member = "group:${var.gcp_trainer_group}"
      roles = [
        "roles/editor",
        "roles/iap.tunnelResourceAccessor",
        "roles/container.admin"
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
  project  = data.google_project.this.name
  role     = each.value.role
  member   = each.value.member

  #Cloud Build creates the SA after enabling the API, so we need it to be enabled first
  depends_on = [
    google_project_service.this
  ]
}