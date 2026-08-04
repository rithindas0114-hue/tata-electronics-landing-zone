#############################################
# LOCALS
#############################################

locals {
  env_map = flatten([
    for bu, config in var.business_units : [
      for env in config.environments : {
        key = "${bu}-${env}"
        bu  = bu
        env = env
      }
    ]
  ])

  project_map = flatten([
    for bu, config in var.business_units : [
      for env, proj in config.projects : {
        key        = "${bu}-${env}"
        bu         = bu
        env        = env
        project_id = proj
      }
    ]
  ])
}

#############################################
# FOLDERS
#############################################

module "bu_folders" {
  source   = "./modules/folder"
  for_each = var.business_units

  folder_name = each.key
  parent      = "organizations/${var.organization_id}"
}

module "env_folders" {
  source = "./modules/folder"

  for_each = {
    for item in local.env_map : item.key => item
  }

  folder_name = each.value.env
  parent      = module.bu_folders[each.value.bu].folder_id
}

#############################################
# PROJECTS
#############################################

module "projects" {
  source = "./modules/project"

  for_each = {
    for item in local.project_map : item.key => item
  }

  project_id      = each.value.project_id
  billing_account = var.billing_account
  folder_id       = module.env_folders["${each.value.bu}-${each.value.env}"].folder_id
}

#############################################
# SHARED SERVICES + NETWORK PROJECT
#############################################

module "shared_services" {
  source = "./modules/folder"

  folder_name = "shared-services"
  parent      = "organizations/${var.organization_id}"
}

module "network_project" {
  source = "./modules/project"

  project_id      = "tepl-ss-networking"
  billing_account = var.billing_account
  folder_id       = module.shared_services.folder_id
}

#############################################
# SHARED VPC HOST
#############################################

resource "google_compute_shared_vpc_host_project" "host" {
  project = module.network_project.project_id
}

#############################################
# HUB NETWORK
#############################################

module "hub_vpc" {
  source = "./modules/network"

  project_id   = module.network_project.project_id
  network_name = "hub-vpc"

  subnets = var.hub_subnets
  enable_shared_vpc_host   = true
  enable_nat               = true
  enable_firewall          = true
}

#############################################
# SPOKES (ATTACH TO HUB)
#############################################

module "spokes" {
  source = "./modules/network"

  for_each = module.projects

  project_id   = each.value.project_id
  network_name = "spoke-${each.key}"

  is_hub          = false
  host_project_id = module.network_project.project_id

  depends_on = [
    module.hub_vpc
  ]
}

#############################################
# VPN (OPTIONAL)
#############################################

module "vpn" {
  source = "./modules/vpn-classic"

  project_id = module.network_project.project_id
  region     = "asia-south1"

  network = module.hub_vpc.network_name

  peer_ip       = var.onprem_peer_ip
  shared_secret = var.vpn_shared_secret

  local_cidr = "10.175.0.0/16"

  remote_cidr = var.onprem_cidr
}

#############################################
# ORG POLICIES
#############################################

resource "google_org_policy_policy" "disable_external_ip" {
  name   = "organizations/${var.organization_id}/policies/compute.vmExternalIpAccess"

  spec {
    rules {
      enforce = true
    }
  }
}

#############################################
# IAM (ORG LEVEL)
#############################################

resource "google_organization_iam_binding" "org_admins" {
  org_id = var.organization_id
  role   = "roles/resourcemanager.organizationAdmin"

  members = var.org_admins
}

#############################################
# BUDGET
#############################################

resource "google_billing_budget" "org_budget" {
  billing_account = var.billing_account

  display_name = "org-budget"

  budget_filter {}

  amount {
    specified_amount {
      currency_code = "USD"
      units         = var.budget_amount
    }
  }

  threshold_rules {
    threshold_percent = 0.8
  }
}

#############################################
# LOGGING SINK (ORG LEVEL)
#############################################

resource "google_logging_organization_sink" "org_sink" {
  name        = "org-logs"
  destination = "storage.googleapis.com/${var.log_bucket}"
  org_id      = var.organization_id

  include_children = true
}

#############################################
# VPC SERVICE CONTROLS
#############################################

resource "google_access_context_manager_access_policy" "policy" {
  parent = "organizations/${var.organization_id}"
  title  = "access-policy"
}

resource "google_access_context_manager_access_level" "corp" {
  parent = google_access_context_manager_access_policy.policy.name
  name   = "${google_access_context_manager_access_policy.policy.name}/accessLevels/corp"

  basic {
    conditions {
      ip_subnetworks = var.corp_ip_ranges
    }
  }
}

data "google_project" "all_projects" {
  for_each  = module.projects
  project_id = each.value.project_id
}

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent = google_access_context_manager_access_policy.policy.name
  name   = "${google_access_context_manager_access_policy.policy.name}/servicePerimeters/perimeter"

  status {
    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com"
    ]

    resources = [
      for p in data.google_project.all_projects :
      "projects/${p.number}"
    ]

    access_levels = [
      google_access_context_manager_access_level.corp.name
    ]
  }
}
