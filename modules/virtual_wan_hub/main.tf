# Create Virtual WAN
resource "azurerm_virtual_wan" "vwan" {
  name                = var.vwan_name
  resource_group_name = var.vwan_resource_group
  location            = var.vwan_location
  type                = var.vwan_type

  lifecycle {
    ignore_changes = [tags]  # Ignore tag changes
  }
}

# Region 1: Create Virtual Hub
resource "azurerm_virtual_hub" "hub1" {
  name                = var.r1_hub_name
  resource_group_name = var.vwan_resource_group
  location            = var.r1_hub_location
  address_prefix      = var.r1_hub_address_prefix
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  sku                 = var.r1_hub_sku
  lifecycle {
    ignore_changes = [tags]  # Ignore tag changes
  }
}

# Region 2: Create Virtual Hub
resource "azurerm_virtual_hub" "hub2" {
  name                = var.r2_hub_name
  resource_group_name = var.vwan_resource_group
  location            = var.r2_hub_location
  address_prefix      = var.r2_hub_address_prefix
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  sku                 = var.r2_hub_sku
  lifecycle {
    ignore_changes = [tags]  # Ignore tag changes
  }
}


# Output for Hub 1 ID
output "hub1_id" {
  value = azurerm_virtual_hub.hub1.id
}

# Output for Hub 2 ID
output "hub2_id" {
  value = azurerm_virtual_hub.hub2.id
}

# Output for Virtual WAN ID
output "vwan_id" {
  value = azurerm_virtual_wan.vwan.id
}

output "hub_ready" {
  value = true
}
