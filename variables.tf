# Subscription details
variable "subscription_id" {
  description = "Subscription ID for Azure"
  type        = string
}

variable "client_id" {
  description = "Client ID for authenticating with Azure"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID for authenticating with Azure"
  type        = string
}

variable "authentication_method" {
  description = "Authentication method to use"
  type        = string
}

# Virtual WAN parameters
variable "vwan_name" {
  description = "Virtual WAN Name"
  type        = string
}

variable "vwan_resource_group" {
  description = "Resource Group for Virtual WAN"
  type        = string
}

variable "vwan_location" {
  description = "Location for Virtual WAN"
  type        = string
}

variable "vwan_type" {
  description = "Type of Virtual WAN"
  type        = string
}

# Region 1 Variables
variable "r1_hub_name" {
  description = "Hub Name for Region 1"
  type        = string
}

variable "r1_hub_location" {
  description = "Hub Location for Region 1"
  type        = string
}

variable "r1_hub_address_prefix" {
  description = "Address Prefix for Hub in Region 1"
  type        = string
}

variable "r1_hub_sku" {
  description = "Hub SKU for Region 1"
  type        = string
}

variable "r1_nva_subnets" {
  description = "Subnet addresses for Region 1 NVAs"
  type        = list(string)
}

# Region 2 Variables
variable "r2_hub_name" {
  description = "Hub Name for Region 2"
  type        = string
}

variable "r2_hub_location" {
  description = "Hub Location for Region 2"
  type        = string
}

variable "r2_hub_address_prefix" {
  description = "Address Prefix for Hub in Region 2"
  type        = string
}

variable "r2_hub_sku" {
  description = "Hub SKU for Region 2"
  type        = string
}

variable "r2_nva_subnets" {
  description = "Subnet addresses for Region 2 NVAs"
  type        = list(string)
}

# Common NVA Details
variable "vm_size" {
  description = "VM size for the NVAs"
  type        = string
}

variable "detach_public_ip" {
  description = "Flag to detach the public IP"
  type        = bool
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses allowed for SSH access"
  type        = list(string)
}

variable "route_to_internet_ips" {
  description = "IPs to route to the internet"
  type        = string
}

variable "vm_admin_username" {
  description = "Admin username for the VMs"
  type        = string
}

variable "vm_ssh_key" {
  description = "SSH key for VM access"
  type        = string
}

variable "client_secret" {
  description = "Client secret for authentication"
  type        = string
  sensitive   = true  # Ensures the value is treated as sensitive
}

variable "resource-group-name" {
  type    = string
  default = "tf-managed-app-resource-group"
}

variable "location" {
  type    = string
  default = "westcentralus"
}

variable "managed-app-name" {
  type    = string
  default = "tf-vwan-managed-app-nva"
}

variable "nva-rg-name" {
  type    = string
  default = "tf-vwan-nva-rg"
}

variable "nva-name" {
  type    = string
  default = "tf-vwan-nva"
}

variable "os-version" {
  description = "GAIA OS version"
  type = string
  default = "R8120"
  validation {
    condition = contains(["R8110", "R8120"], var.os-version)
    error_message = "Allowed values for os-version are 'R8110', 'R8120'"
  }
}

variable "license-type" {
  type    = string
  default = "Security Enforcement (NGTP)"
  validation {
    condition     = contains(["Security Enforcement (NGTP)", "Full Package (NGTX + S1C)", "Full Package Premium (NGTX + S1C++)"], var.license-type)
    error_message = "Allowed values for License Type are 'Security Enforcement (NGTP)', 'Full Package (NGTX + S1C)', 'Full Package Premium (NGTX + S1C++)'"
  }
}

variable "scale-unit" {
  type    = string
  default = "2"
  validation {
    condition     = contains(["2", "4", "10", "20", "30", "60", "80"], var.scale-unit)
    error_message = "Valid values for CloudGuard version are '2', '4', '10', '20', '30', '60', '80'"
  }
}

variable "bootstrap-script" {
  type    = string
  default = ""
}

variable "admin-shell" {
  type    = string
  default = "/etc/cli.sh"
  validation {
    condition     = contains(["/etc/cli.sh", "/bin/bash", "/bin/tcsh", "/bin/csh"], var.admin-shell)
    error_message = "Valid shells are '/etc/cli.sh', '/bin/bash', '/bin/tcsh', '/bin/csh'"
  }
}

variable "sic-key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "ssh-public-key" {
  type    = string
  default = ""
}

variable "bgp-asn" {
  type    = string
  default = "64512"
  validation {
    condition = tonumber(var.bgp-asn) >= 64512 && tonumber(var.bgp-asn) <= 65534 && !contains([65515, 65520], tonumber(var.bgp-asn))
    error_message = "Only numbers between 64512 to 65534 are allowed excluding 65515, 65520."
  }
}

variable "custom-metrics" {
  type    = string
  default = "yes"
  validation {
    condition     = contains(["yes", "no"], var.custom-metrics)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

variable "routing-intent-internet-traffic" {
  default = "yes"
  validation {
    condition     = contains(["yes", "no"], var.routing-intent-internet-traffic)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

variable "routing-intent-private-traffic" {
  default = "yes"
  validation {
    condition     = contains(["yes", "no"], var.routing-intent-private-traffic)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

variable "smart1-cloud-token-a" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-b" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-c" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-d" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-e" {
  type    = string
  default = ""
}

variable "existing-public-ip" {
  type = string
  default = ""  
}

variable "new-public-ip" {
  type = string
  default = "no"
    validation {
    condition     = contains(["yes", "no"], var.new-public-ip)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

# Region 1 variables
variable "r1_resource-group-name" {
  description = "Resource group name for Region 1"
  type        = string
}

variable "r1_managed-app-name" {
  description = "Managed application name for Region 1"
  type        = string
}

variable "r1_nva-rg-name" {
  description = "NVA resource group name for Region 1"
  type        = string
}

variable "r1_nva-name" {
  description = "NVA name for Region 1"
  type        = string
}

variable "r1_os-version" {
  description = "OS version for Region 1"
  type        = string
}

variable "r1_license-type" {
  description = "License type for Region 1"
  type        = string
}

variable "r1_scale-unit" {
  description = "Scale unit for Region 1"
  type        = string
}

variable "r1_bootstrap-script" {
  description = "Bootstrap script for Region 1"
  type        = string
}

variable "r1_admin-shell" {
  description = "Admin shell for Region 1"
  type        = string
}

variable "r1_sic-key" {
  description = "SIC key for Region 1"
  type        = string
}

variable "r1_bgp-asn" {
  description = "BGP ASN for Region 1"
  type        = string
}

variable "r1_custom-metrics" {
  description = "Custom metrics for Region 1"
  type        = string
}

variable "r1_routing-intent-internet-traffic" {
  description = "Routing intent for internet traffic in Region 1"
  type        = string
}

variable "r1_routing-intent-private-traffic" {
  description = "Routing intent for private traffic in Region 1"
  type        = string
}

variable "r1_smart1-cloud-token-a" {
  description = "Smart-1 cloud token A for Region 1"
  type        = string
}

variable "r1_smart1-cloud-token-b" {
  description = "Smart-1 cloud token B for Region 1"
  type        = string
}

variable "r1_smart1-cloud-token-c" {
  description = "Smart-1 cloud token C for Region 1"
  type        = string
}

variable "r1_smart1-cloud-token-d" {
  description = "Smart-1 cloud token D for Region 1"
  type        = string
}

variable "r1_smart1-cloud-token-e" {
  description = "Smart-1 cloud token E for Region 1"
  type        = string
}

variable "r1_existing-public-ip" {
  description = "Existing public IP for Region 1"
  type        = string
}

variable "r1_new-public-ip" {
  description = "New public IP for Region 1"
  type        = string
}

# Region 2 variables
variable "r2_resource-group-name" {
  description = "Resource group name for Region 2"
  type        = string
}

variable "r2_managed-app-name" {
  description = "Managed application name for Region 2"
  type        = string
}

variable "r2_nva-rg-name" {
  description = "NVA resource group name for Region 2"
  type        = string
}

variable "r2_nva-name" {
  description = "NVA name for Region 2"
  type        = string
}

variable "r2_os-version" {
  description = "OS version for Region 2"
  type        = string
}

variable "r2_license-type" {
  description = "License type for Region 2"
  type        = string
}

variable "r2_scale-unit" {
  description = "Scale unit for Region 2"
  type        = string
}

variable "r2_bootstrap-script" {
  description = "Bootstrap script for Region 2"
  type        = string
}

variable "r2_admin-shell" {
  description = "Admin shell for Region 2"
  type        = string
}

variable "r2_sic-key" {
  description = "SIC key for Region 2"
  type        = string
}

variable "r2_bgp-asn" {
  description = "BGP ASN for Region 2"
  type        = string
}

variable "r2_custom-metrics" {
  description = "Custom metrics for Region 2"
  type        = string
}

variable "r2_routing-intent-internet-traffic" {
  description = "Routing intent for internet traffic in Region 2"
  type        = string
}

variable "r2_routing-intent-private-traffic" {
  description = "Routing intent for private traffic in Region 2"
  type        = string
}

variable "r2_smart1-cloud-token-a" {
  description = "Smart-1 cloud token A for Region 2"
  type        = string
}

variable "r2_smart1-cloud-token-b" {
  description = "Smart-1 cloud token B for Region 2"
  type        = string
}

variable "r2_smart1-cloud-token-c" {
  description = "Smart-1 cloud token C for Region 2"
  type        = string
}

variable "r2_smart1-cloud-token-d" {
  description = "Smart-1 cloud token D for Region 2"
  type        = string
}

variable "r2_smart1-cloud-token-e" {
  description = "Smart-1 cloud token E for Region 2"
  type        = string
}

variable "r2_existing-public-ip" {
  description = "Existing public IP for Region 2"
  type        = string
}

variable "r2_new-public-ip" {
  description = "New public IP for Region 2"
  type        = string
}

locals{
  # Validate that new-public-ip is false when existing-public-ip is used
  is_both_params_used = length(var.existing-public-ip) > 0 && var.new-public-ip == "yes"
  validation_message_both = "Only one parameter of existing-public-ip or new-public-ip can be used"
  _ = regex("^$", (!local.is_both_params_used ? "" : local.validation_message_both))
}