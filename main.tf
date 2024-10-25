####################################################################################################
# Resource Group for Virtual WAN and other resources
resource "azurerm_resource_group" "vwan_rg" {
  name     = var.vwan_resource_group
  location = var.vwan_location
}

####################################################################################################
# Step 1: Create Virtual WAN and Hubs
module "virtual_wan_hub" {
  source = "./modules/virtual_wan_hub"

  vwan_name           = var.vwan_name
  vwan_resource_group = azurerm_resource_group.vwan_rg.name 
  vwan_location       = var.vwan_location
  vwan_type           = var.vwan_type
  
  r1_hub_name         = var.r1_hub_name
  r1_hub_location     = var.r1_hub_location
  r1_hub_address_prefix = var.r1_hub_address_prefix
  r1_hub_sku          = var.r1_hub_sku
  
  r2_hub_name         = var.r2_hub_name
  r2_hub_location     = var.r2_hub_location
  r2_hub_address_prefix = var.r2_hub_address_prefix
  r2_hub_sku          = var.r2_hub_sku

}

####################################################################################################
# Step 2: Create Ubuntu NVAs, VNets, NSGs, and Public IPs
module "ubuntu_nvas" {
  source = "./modules/ubuntu_nvas"

  # VNets and NVAs configuration
  vwan_resource_group = azurerm_resource_group.vwan_rg.name 
  r1_hub_name         = var.r1_hub_name
  r1_hub_location     = var.r1_hub_location
  r1_nva_subnets      = var.r1_nva_subnets

  r2_hub_name         = var.r2_hub_name
  r2_hub_location     = var.r2_hub_location
  r2_nva_subnets      = var.r2_nva_subnets

  # VM and networking configurations
  vm_size             = var.vm_size
  vm_admin_username   = var.vm_admin_username
  vm_ssh_key          = var.vm_ssh_key
  allowed_ssh_ips     = var.allowed_ssh_ips
  route_to_internet_ips = var.route_to_internet_ips

  # Pass hub IDs from the virtual_wan_hub module
  hub1_id = module.virtual_wan_hub.hub1_id
  hub2_id = module.virtual_wan_hub.hub2_id
}

####################################################################################################
# Step 3: Attach NVAs' VNets to Virtual WAN Hubs
module "vnet_hub_connection" {
  source = "./modules/vnet_hub_connection"

  vnets_region1      = module.ubuntu_nvas.vnets_region1
  vnets_region2      = module.ubuntu_nvas.vnets_region2
  hub1_id            = module.virtual_wan_hub.hub1_id
  hub2_id            = module.virtual_wan_hub.hub2_id
  vwan_resource_group = azurerm_resource_group.vwan_rg.name
}

####################################################################################################
# Step 4: Create CGNS for Virtual WAN
# Region 1

module "r1_cgns" {
  source              = "./modules/cgns"

  vwan-hub-resource-group = var.vwan_resource_group

  client_id           = var.client_id
  client_secret       = var.client_secret
  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  location            = var.r1_hub_location 
  vwan-hub-name       = var.r1_hub_name
  ssh-public-key      = var.vm_ssh_key
  authentication_method = var.authentication_method
  resource-group-name = var.r1_resource-group-name
  managed-app-name    = var.r1_managed-app-name
  nva-rg-name         = var.r1_nva-rg-name
  nva-name            = var.r1_nva-name
  os-version          = var.r1_os-version
  license-type        = var.r1_license-type
  scale-unit          = var.r1_scale-unit
  bootstrap-script    = var.r1_bootstrap-script
  admin-shell         = var.r1_admin-shell
  sic-key             = var.r1_sic-key
  bgp-asn             = var.r1_bgp-asn
  custom-metrics      = var.r1_custom-metrics
  routing-intent-internet-traffic = var.r1_routing-intent-internet-traffic
  routing-intent-private-traffic = var.r1_routing-intent-private-traffic
  smart1-cloud-token-a = var.r1_smart1-cloud-token-a
  smart1-cloud-token-b = var.r1_smart1-cloud-token-b
  smart1-cloud-token-c = var.r1_smart1-cloud-token-c
  smart1-cloud-token-d = var.r1_smart1-cloud-token-d
  smart1-cloud-token-e = var.r1_smart1-cloud-token-e
  existing-public-ip  = var.r1_existing-public-ip
  new-public-ip       = var.r1_new-public-ip
}

# Create CGNS for Region 2

module "r2_cgns" {
  source              = "./modules/cgns"

  vwan-hub-resource-group = var.vwan_resource_group

  client_id           = var.client_id
  client_secret       = var.client_secret
  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  location            = var.r2_hub_location
  vwan-hub-name       = var.r2_hub_name
  ssh-public-key      = var.vm_ssh_key
  authentication_method = var.authentication_method
  resource-group-name = var.r2_resource-group-name
  managed-app-name    = var.r2_managed-app-name
  nva-rg-name         = var.r2_nva-rg-name
  nva-name            = var.r2_nva-name
  os-version          = var.r2_os-version
  license-type     = var.r2_license-type
  scale-unit          = var.r2_scale-unit
  bootstrap-script    = var.r2_bootstrap-script
  admin-shell         = var.r2_admin-shell
  sic-key          = var.r2_sic-key
  bgp-asn             = var.r2_bgp-asn
  custom-metrics      = var.r2_custom-metrics
  routing-intent-internet-traffic = var.r2_routing-intent-internet-traffic
  routing-intent-private-traffic = var.r2_routing-intent-private-traffic
  smart1-cloud-token-a = var.r2_smart1-cloud-token-a
  smart1-cloud-token-b = var.r2_smart1-cloud-token-b
  smart1-cloud-token-c = var.r2_smart1-cloud-token-c
  smart1-cloud-token-d = var.r2_smart1-cloud-token-d
  smart1-cloud-token-e = var.r2_smart1-cloud-token-e
  existing-public-ip  = var.r2_existing-public-ip
  new-public-ip       = var.r2_new-public-ip
}
