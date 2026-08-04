#############################################
# STATIC EXTERNAL IP (VPN GATEWAY)
#############################################

resource "google_compute_address" "vpn_ip" {
  name    = "vpn-ip"
  project = var.project_id
  region  = var.region
}

#############################################
# TARGET VPN GATEWAY
#############################################

resource "google_compute_target_vpn_gateway" "vpn_gateway" {
  name    = "vpn-gateway"
  network = var.network
  project = var.project_id
  region  = var.region
}

#############################################
# FORWARDING RULES
#############################################

resource "google_compute_forwarding_rule" "esp" {
  name        = "vpn-esp"
  project     = var.project_id
  region      = var.region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_target_vpn_gateway.vpn_gateway.id
}

resource "google_compute_forwarding_rule" "udp500" {
  name        = "vpn-udp500"
  project     = var.project_id
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_target_vpn_gateway.vpn_gateway.id
}

resource "google_compute_forwarding_rule" "udp4500" {
  name        = "vpn-udp4500"
  project     = var.project_id
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_target_vpn_gateway.vpn_gateway.id
}

#############################################
# VPN TUNNEL
#############################################

resource "google_compute_vpn_tunnel" "tunnel" {
  name               = "vpn-tunnel"
  project            = var.project_id
  region             = var.region
  target_vpn_gateway = google_compute_target_vpn_gateway.vpn_gateway.id

  peer_ip       = var.peer_ip
  shared_secret = var.shared_secret

  local_traffic_selector  = [var.local_cidr]
  remote_traffic_selector = [var.remote_cidr]
}

#############################################
# ROUTE TO ON-PREM
#############################################

resource "google_compute_route" "onprem_route" {
  name       = "route-to-onprem"
  project    = var.project_id
  network    = var.network
  dest_range = var.remote_cidr

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel.id
  priority            = 1000
}
