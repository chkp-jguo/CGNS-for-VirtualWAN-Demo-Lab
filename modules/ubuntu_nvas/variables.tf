# Virtual WAN parameters
variable "vwan_resource_group" {
  description = "Resource group for the Virtual WAN"
  type        = string
}

variable "r1_hub_location" {
  description = "Location of the Region 1 hub"
  type        = string
}

variable "r2_hub_location" {
  description = "Location of the Region 2 hub"
  type        = string
}

variable "r1_hub_name" {
  description = "Name of the Region 1 hub"
  type        = string
}

variable "r2_hub_name" {
  description = "Name of the Region 2 hub"
  type        = string
}

# Region 1 Subnet List
variable "r1_nva_subnets" {
  description = "List of subnet address spaces for Region 1 NVAs"
  type        = list(string)
}

# Region 2 Subnet List
variable "r2_nva_subnets" {
  description = "List of subnet address spaces for Region 2 NVAs"
  type        = list(string)
}

# NVA VM Details
variable "vm_size" {
  description = "Size of the VMs"
  type        = string
}

variable "allowed_ssh_ips" {
  description = "List of allowed IPs for SSH access"
  type        = list(string)
}

variable "route_to_internet_ips" {
  description = "IP address or range to route traffic to the internet"
  type        = string
}

variable "vm_admin_username" {
  description = "Admin username for the VMs"
  type        = string
}

variable "vm_ssh_key" {
  description = "SSH public key for VM access"
  type        = string
}

# Virtual WAN Hub dependencies
variable "hub1_id" {
  description = "ID of the Virtual WAN Hub 1"
  type        = string
}

variable "hub2_id" {
  description = "ID of the Virtual WAN Hub 2"
  type        = string
}
