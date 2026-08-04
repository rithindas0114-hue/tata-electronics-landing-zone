provider "google" {
  project = "dummy-project" # not used heavily at root
  region  = "asia-south1"
}

provider "google-beta" {
  project = "dummy-project"
  region  = "asia-south1"
}
