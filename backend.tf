terraform {
  backend "gcs" {
    bucket  = "tepl-terraform-state"
    prefix  = "landing-zone"
  }
}
