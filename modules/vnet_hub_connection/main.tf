# Connect Region 1 VNets to the Virtual WAN hub
resource "azurerm_virtual_hub_connection" "region1_nva_connections" {
  count = length(var.vnets_region1)

  name                      = "hub1-connection-${count.index + 1}"
  virtual_hub_id            = var.hub1_id  # Passed from the root module or another module output
  remote_virtual_network_id = var.vnets_region1[count.index]
}

# Connect Region 2 VNets to the Virtual WAN hub
resource "azurerm_virtual_hub_connection" "region2_nva_connections" {
  count = length(var.vnets_region2)

  name                      = "hub2-connection-${count.index + 1}"
  virtual_hub_id            = var.hub2_id  # Passed from the root module or another module output
  remote_virtual_network_id = var.vnets_region2[count.index]
}