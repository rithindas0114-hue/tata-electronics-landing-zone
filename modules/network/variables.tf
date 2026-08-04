variable "project_id" {
  type = string
}

variable "network_name" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-south1"
}

#############################################
# HUB / SPOKE SWITCH
#############################################

variable "is_hub" {
  type        = bool
  description = "Whether this project is the Shared VPC host"
}

#############################################
# HUB CONFIG
#############################################

variable "subnets" {
  description = "Map of subnets for hub VPC"
  type = map(object({
    cidr   = string
    region = string
  }))
  default = {}
}

#############################################
# SPOKE CONFIG
#############################################

variable "host_project_id" {
  type    = string
  default = null
}

#############################################
# FEATURES
#############################################

variable "enable_firewall" {
  type    = bool
  default = true
}

variable "enable_nat" {
  type    = bool
  default = true
}
