data "azurerm_client_config" "core" {
  provider = azurerm
}
data "azurerm_client_config" "management" {
  provider = azurerm.management
}
data "azurerm_client_config" "connectivity" {
  provider = azurerm.connectivity
}
data "azurerm_client_config" "identity" {
  provider = azurerm.identity
}
module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "4.2.0"

  default_location = var.default_location

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
    azurerm.identity     = azurerm.identity
  }
  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name
}
resource "azurerm_resource_group" "rg" {
    name =   "${var.prefix}-REB-RG"
    location = var.resource_group_location
}

resource "azurerm_virtual_network" "vnet1" {
  name = "${var.prefix}-vnet1"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.resource_group_location
  address_space = ["10.0.0.0/24"]

}

resource "azurerm_subnet" "snet1" {
  name = "${var.prefix}-snet1"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes = ["10.0.0.0/26"]
  depends_on = [ azurerm_virtual_network.vnet1, azurerm_network_security_group.nsg1 ]
}

resource "azurerm_network_security_group" "nsg1" {
  name = "${var.prefix}-nsg1"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_virtual_network.vnet1.location
}

resource "azurerm_subnet_network_security_group_association" "snetnsga1" {
  network_security_group_id = azurerm_network_security_group.nsg1.id
  subnet_id = azurerm_subnet.snet1.id
}

resource "azurerm_network_security_rule" "nsr1" {
    name = "allow_https_inbound"
    resource_group_name = azurerm_resource_group.rg.name
    priority = "1001"
    network_security_group_name = azurerm_network_security_group.nsg1.name
    protocol = "Tcp"
    access = "Allow"
    direction = "Inbound"
    source_address_prefix = "10.0.0.0/26"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = "443"  
    depends_on = [ azurerm_network_security_group.nsg1 ]
}
resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}
resource "azurerm_network_security_rule" "nsr2" {
    name = "allow_http_inbound"
    resource_group_name = azurerm_resource_group.rg.name
    priority = "1002"
    network_security_group_name = azurerm_network_security_group.nsg1.name
    protocol = "Tcp"
    access = "Allow"
    direction = "Inbound"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = "80"  
    depends_on = [ azurerm_network_security_group.nsg1 ]
}
resource "azurerm_network_security_rule" "nsr3" {
    name = "allow_rdp_inbound"
    resource_group_name = azurerm_resource_group.rg.name
    priority = "1003"
    network_security_group_name = azurerm_network_security_group.nsg1.name
    protocol = "*"
    access = "Allow"
    direction = "Inbound"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = "3389"  
    depends_on = [ azurerm_network_security_group.nsg1 ]
}
resource "azurerm_public_ip" "pip1" {
  name = "pip1"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Static"
}
resource "azurerm_network_interface" "nic1" {
  name = "nic1"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  ip_configuration {
    name = "nic-ip1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.snet1.id
    public_ip_address_id = azurerm_public_ip.pip1.id
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name = "vm1"  
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  admin_username = "AJAdmin"
  admin_password = random_password.password.result
  size = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nic1.id]
  os_disk {
    name = "osdiskvm1"
    storage_account_type = "Premium_LRS"
    caching = "ReadWrite"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine_extension" "vme1" {
  name = "vme1"
  virtual_machine_id = azurerm_windows_virtual_machine.vm1.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"

  settings = <<SETTINGS
  {
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
  }
  SETTINGS
}
