resource "google_monitoring_alert_policy" "alert" {
  display_name = var.name
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "CPU Usage"

    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "60s"
    }
  }
}
