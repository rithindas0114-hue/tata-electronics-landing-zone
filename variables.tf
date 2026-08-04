variable "organization_id" {}
variable "billing_account" {}

variable "region" {
  default = "asia-south1"
}

variable "business_units" {
  type = map(object({
    environments = list(string)
    projects     = map(string)
  }))
}

# VPN
variable "peer_ip" {}
variable "shared_secret" {}

# IAM
variable "org_admins" {
  type = list(string)
}

# Budget
variable "budget_amount" {
  default = 1000
}

# Logging
variable "log_bucket" {}

# VPC-SC
variable "corp_ip_ranges" {
  type = list(string)
}
variable "onprem_peer_ip" {}

variable "vpn_shared_secret" {}

variable "onprem_cidr" {}

variable "hub_subnets" {
  description = "Subnets for hub VPC"
  type = map(object({
    cidr   = string
    region = string
  }))
}
