//********************** Region 1 **************************//


# Create a separate resource group for each NVA in Region 1
resource "azurerm_resource_group" "nva_rg_r1" {
  count = length(var.r1_nva_subnets)
  
  name     = "r1-nva-rg-${format("%02d", count.index + 1)}"
  location = var.r1_hub_location
}

# Create VNets for each NVA in Region 1
resource "azurerm_virtual_network" "vnet_r1" {
  count               = length(var.r1_nva_subnets)
  name                = "r1-vnet-${format("%02d", count.index + 1)}"
  address_space       = [var.r1_nva_subnets[count.index]]
  location            = var.r1_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r1[count.index].name

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Subnets for each VNet in Region 1
resource "azurerm_subnet" "subnet_r1" {
  count               = length(var.r1_nva_subnets)
  name                = "subnet-${format("%02d", count.index + 1)}"
  virtual_network_name = azurerm_virtual_network.vnet_r1[count.index].name
  address_prefixes    = [var.r1_nva_subnets[count.index]]
  resource_group_name = azurerm_resource_group.nva_rg_r1[count.index].name
}

# Create NSG for each NVA in Region 1
resource "azurerm_network_security_group" "nsg_r1" {
  count               = length(var.r1_nva_subnets)
  name                = "${var.r1_hub_name}-nsg-${format("%02d", count.index + 1)}"
  location            = var.r1_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r1[count.index].name

  # Allow SSH from specific IP ranges
  security_rule {
    name                       = "Allow_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  # Allow iPerf (5201) traffic for testing
  security_rule {
    name                       = "Allow_iPerf"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["5201"]
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "Allow_All_Outbound"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "Deny_All_Inbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Network Interface for each NVA in Region 1
resource "azurerm_network_interface" "nic_r1" {
  count               = length(var.r1_nva_subnets)
  name                = "vm-${format("%02d", count.index + 1)}-nic"
  location            = var.r1_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r1[count.index].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_r1[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_r1[count.index].id
  }

  lifecycle {
    ignore_changes = [tags]
    prevent_destroy = false
  }
}

# Create Public IP for each NVA in Region 1
resource "azurerm_public_ip" "pip_r1" {
  count               = length(var.r1_nva_subnets)
  name                = "r1-vm-${format("%02d", count.index + 1)}-pip"
  location            = var.r1_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r1[count.index].name
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Virtual Machines for NVAs in Region 1
resource "azurerm_virtual_machine" "nvas_r1" {
  count = length(var.r1_nva_subnets)

  name                = "r1-vm-${format("%02d", count.index + 1)}"
  location            = var.r1_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r1[count.index].name
  network_interface_ids = [azurerm_network_interface.nic_r1[count.index].id]
  vm_size             = var.vm_size

  os_profile {
    computer_name  = "r1-vm-${format("%02d", count.index + 1)}"
    admin_username = var.vm_admin_username
    custom_data    = filebase64("cloud-init.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
      key_data = var.vm_ssh_key
    }
  }

  storage_os_disk {
    name              = "r1-vm-${format("%02d", count.index + 1)}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [tags]
    prevent_destroy = false
  }

  depends_on = [azurerm_network_interface.nic_r1]
}

# Attach NSG to Subnets in Region 1
resource "azurerm_subnet_network_security_group_association" "nsg_association_r1" {
  count = length(var.r1_nva_subnets)

  subnet_id                 = azurerm_subnet.subnet_r1[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_r1[count.index].id
}


# Create Route Table for Region 1 NVAs
resource "azurerm_route_table" "nva_route_table_r1" {
  count = length(var.r1_nva_subnets)

  name                = "${var.r1_hub_name}-nva-route-table-${format("%02d", count.index + 1)}"
  location            = var.r1_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r1[count.index].name

  route {
    name           = "to-internet"
    address_prefix = var.route_to_internet_ips
    next_hop_type  = "Internet"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Attach Route Table to Subnets in Region 1
resource "azurerm_subnet_route_table_association" "nva_route_r1" {
  count = length(var.r1_nva_subnets)

  subnet_id      = azurerm_subnet.subnet_r1[count.index].id
  route_table_id = azurerm_route_table.nva_route_table_r1[count.index].id
}

//********************** Region 2 **************************//


# Create a separate resource group for each NVA in Region 2
resource "azurerm_resource_group" "nva_rg_r2" {
  count = length(var.r2_nva_subnets)
  
  name     = "r2-nva-rg-${format("%02d", count.index + 1)}"
  location = var.r2_hub_location
}

# Create VNets for each NVA in Region 2
resource "azurerm_virtual_network" "vnet_r2" {
  count               = length(var.r2_nva_subnets)
  name                = "r2-vnet-${format("%02d", count.index + 1)}"
  address_space       = [var.r2_nva_subnets[count.index]]
  location            = var.r2_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r2[count.index].name

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Subnets for each VNet in Region 2
resource "azurerm_subnet" "subnet_r2" {
  count               = length(var.r2_nva_subnets)
  name                = "subnet-${format("%02d", count.index + 1)}"
  virtual_network_name = azurerm_virtual_network.vnet_r2[count.index].name
  address_prefixes    = [var.r2_nva_subnets[count.index]]
  resource_group_name = azurerm_resource_group.nva_rg_r2[count.index].name
}

# Create NSG for each NVA in Region 2
resource "azurerm_network_security_group" "nsg_r2" {
  count               = length(var.r2_nva_subnets)
  name                = "${var.r2_hub_name}-nsg-${format("%02d", count.index + 1)}"
  location            = var.r2_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r2[count.index].name

  # Allow SSH from specific IP ranges
  security_rule {
    name                       = "Allow_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  # Allow iPerf (5201) traffic for testing
  security_rule {
    name                       = "Allow_iPerf"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["5201"]
    source_address_prefixes    = var.allowed_ssh_ips
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "Allow_All_Outbound"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "Deny_All_Inbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Network Interface for each NVA in Region 2
resource "azurerm_network_interface" "nic_r2" {
  count               = length(var.r2_nva_subnets)
  name                = "vm-${format("%02d", count.index + 1)}-nic"
  location            = var.r2_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r2[count.index].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_r2[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_r2[count.index].id
  }

  lifecycle {
    ignore_changes = [tags]
    prevent_destroy = false
  }
}

# Create Public IP for each NVA in Region 2
resource "azurerm_public_ip" "pip_r2" {
  count               = length(var.r2_nva_subnets)
  name                = "r2-vm-${format("%02d", count.index + 1)}-pip"
  location            = var.r2_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r2[count.index].name
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    ignore_changes = [tags]
  }
}

# Attach NSG to Subnets in Region 2
resource "azurerm_subnet_network_security_group_association" "nsg_association_r2" {
  count = length(var.r2_nva_subnets)

  subnet_id                 = azurerm_subnet.subnet_r2[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_r2[count.index].id
}


# Create Route Table for Region 2 NVAs
resource "azurerm_route_table" "nva_route_table_r2" {
  count = length(var.r2_nva_subnets)

  name                = "${var.r2_hub_name}-nva-route-table-${format("%02d", count.index + 1)}"
  location            = var.r2_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r2[count.index].name

  route {
    name           = "to-internet"
    address_prefix = var.route_to_internet_ips
    next_hop_type  = "Internet"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Attach Route Table to Subnets in Region 2
resource "azurerm_subnet_route_table_association" "nva_route_r2" {
  count = length(var.r2_nva_subnets)

  subnet_id      = azurerm_subnet.subnet_r2[count.index].id
  route_table_id = azurerm_route_table.nva_route_table_r2[count.index].id
}

# Create Virtual Machines for NVAs in Region 2
resource "azurerm_virtual_machine" "nvas_r2" {
  count = length(var.r2_nva_subnets)

  name                = "r2-vm-${format("%02d", count.index + 1)}"
  location            = var.r2_hub_location
  resource_group_name = azurerm_resource_group.nva_rg_r2[count.index].name
  network_interface_ids = [azurerm_network_interface.nic_r2[count.index].id]
  vm_size             = var.vm_size

  os_profile {
    computer_name  = "r2-vm-${format("%02d", count.index + 1)}"
    admin_username = var.vm_admin_username
    custom_data    = filebase64("cloud-init.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
      key_data = var.vm_ssh_key
    }
  }

  storage_os_disk {
    name              = "r2-vm-${format("%02d", count.index + 1)}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [tags]
    prevent_destroy = false
  }

  depends_on = [azurerm_network_interface.nic_r2]
}

# Output the VNets created for Region 1
output "vnets_region1" {
  value       = [for i in range(length(var.r1_nva_subnets)) : azurerm_virtual_network.vnet_r1[i].id]
  description = "The IDs of the VNets created for Region 1 NVAs"
}

# Output the VNets created for Region 2
output "vnets_region2" {
  value       = [for i in range(length(var.r2_nva_subnets)) : azurerm_virtual_network.vnet_r2[i].id]
  description = "The IDs of the VNets created for Region 2 NVAs"
}