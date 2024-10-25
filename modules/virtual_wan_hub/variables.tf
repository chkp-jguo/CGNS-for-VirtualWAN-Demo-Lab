# Variables for Virtual WAN

variable "vwan_name" {
  description = "Name of the Virtual WAN"
  type        = string
}

variable "vwan_resource_group" {
  description = "Resource group for the Virtual WAN"
  type        = string
}

variable "vwan_location" {
  description = "Location of the Virtual WAN"
  type        = string
}

variable "vwan_type" {
  description = "Type of Virtual WAN"
  type        = string
}

# Variables for Region 1 Hub
variable "r1_hub_name" {
  description = "Name of the Region 1 hub"
  type        = string
}

variable "r1_hub_location" {
  description = "Location of the Region 1 hub"
  type        = string
}

variable "r1_hub_address_prefix" {
  description = "Address prefix for the Region 1 hub"
  type        = string
}

variable "r1_hub_sku" {
  description = "SKU for the Region 1 hub"
  type        = string
}

# Variables for Region 2 Hub
variable "r2_hub_name" {
  description = "Name of the Region 2 hub"
  type        = string
}

variable "r2_hub_location" {
  description = "Location of the Region 2 hub"
  type        = string
}

variable "r2_hub_address_prefix" {
  description = "Address prefix for the Region 2 hub"
  type        = string
}

variable "r2_hub_sku" {
  description = "SKU for the Region 2 hub"
  type        = string
}

