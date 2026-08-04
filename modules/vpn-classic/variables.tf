variable "project_id" {
  type = string
}

variable "region" {
  default = "asia-south1"
}

variable "network" {
  type = string
}

# On-Prem Details
variable "peer_ip" {
  description = "On-prem VPN gateway public IP"
  type        = string
}

variable "shared_secret" {
  description = "Pre-shared key"
  type        = string
}

variable "local_cidr" {
  default = "10.175.0.0/16"
}

variable "remote_cidr" {
  description = "On-prem CIDR"
  type        = string
}
