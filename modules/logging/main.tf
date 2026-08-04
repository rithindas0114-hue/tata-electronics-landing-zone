resource "google_logging_project_sink" "sink" {
  name        = var.name
  destination = var.destination
  project     = var.project_id

  filter = "severity>=ERROR"
}
