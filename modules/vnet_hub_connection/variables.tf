# VNets created by the ubuntu_nvas module in Region 1
variable "vnets_region1" {
  description = "List of VNets for Region 1 NVAs"
  type        = list(string)
}

# VNets created by the ubuntu_nvas module in Region 2
variable "vnets_region2" {
  description = "List of VNets for Region 2 NVAs"
  type        = list(string)
}

# Resource group for the Virtual WAN
variable "vwan_resource_group" {
  description = "Resource group for the Virtual WAN"
  type        = string
}

# ID of Virtual WAN Hub 1
variable "hub1_id" {
  description = "ID of the Region 1 Virtual WAN Hub"
  type        = string
}

# ID of Virtual WAN Hub 2
variable "hub2_id" {
  description = "ID of the Region 2 Virtual WAN Hub"
  type        = string
}