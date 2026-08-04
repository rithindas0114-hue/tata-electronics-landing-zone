output "subnets" {
  value = {
    for k, v in google_compute_subnetwork.subnets :
    k => v.name
  }
}
