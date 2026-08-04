#############################################
# HUB VPC
#############################################

resource "google_compute_network" "vpc" {
  count                   = var.is_hub ? 1 : 0
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
}

#############################################
# HUB SUBNET
#############################################

resource "google_compute_subnetwork" "subnets" {
  for_each = var.is_hub ? var.subnets : {}

  name          = each.key
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.vpc[0].id
  project       = var.project_id

  private_ip_google_access = true
}

#############################################
# ENABLE SHARED VPC HOST
#############################################

resource "google_compute_shared_vpc_host_project" "host" {
  count   = var.is_hub ? 1 : 0
  project = var.project_id
}

#############################################
# ATTACH SPOKE PROJECTS
#############################################

resource "google_compute_shared_vpc_service_project" "service" {
  count = var.is_hub ? 0 : 1

  host_project    = var.host_project_id
  service_project = var.project_id

  depends_on = [
    google_compute_shared_vpc_host_project.host
  ]
}

#############################################
# FIREWALL (HUB ONLY)
#############################################

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  # 🔥 ADD THIS BLOCK (VPN REQUIRED)
  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }

  source_ranges = var.corp_ip_ranges
}

  ##################################
  # INTERNAL TRAFFIC
  ##################################
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  ##################################
  # VPN TRAFFIC
  ##################################
  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }

  source_ranges = ["10.0.0.0/8", "0.0.0.0/0"]
}

#############################################
# CLOUD ROUTER (HUB ONLY)
#############################################

resource "google_compute_router" "router" {
  count   = var.is_hub && var.enable_nat ? 1 : 0
  name    = "${var.network_name}-router"
  network = google_compute_network.vpc[0].id
  region  = var.region
  project = var.project_id

  bgp {
    asn = 64514
  }
}

#############################################
# CLOUD NAT (HUB ONLY)
#############################################

resource "google_compute_router_nat" "nat" {
  count                              = var.is_hub && var.enable_nat ? 1 : 0
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.region
  project                            = var.project_id

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
