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
# module "enterprise_scale" {
#   source  = "Azure/caf-enterprise-scale/azurerm"
#   version = "4.2.0"

#   default_location = var.default_location

#   providers = {
#     azurerm              = azurerm
#     azurerm.connectivity = azurerm.connectivity
#     azurerm.management   = azurerm.management
#     azurerm.identity     = azurerm.identity
#   }
#   root_parent_id = data.azurerm_client_config.core.tenant_id
#   root_id        = var.root_id
#   root_name      = var.root_name
# }
resource "azurerm_resource_group" "rg" {
    name =   "${var.prefix}-REB-RG"
    location = var.resource_group_location
    tags = {
      "key1" = "value1"
    }
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
    destination_port_range = "*"  
    depends_on = [ azurerm_network_security_group.nsg1 ]
}