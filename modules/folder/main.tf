resource "google_project" "project" {
  project_id      = var.project_id
  name            = var.project_id
  billing_account = var.billing_account
  folder_id       = var.folder_id
}
