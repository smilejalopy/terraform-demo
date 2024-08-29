# Existing resources
resource "azurerm_subnet" "snet1" {
  name                 = "${var.prefix}-snet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.0.0/26"]
  depends_on           = [azurerm_virtual_network.vnet1, azurerm_network_security_group.nsg1]
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "${var.prefix}-nsg1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_virtual_network.vnet1.location
}

resource "azurerm_subnet_network_security_group_association" "snetnsga1" {
  network_security_group_id = azurerm_network_security_group.nsg1.id
  subnet_id                 = azurerm_subnet.snet1.id
}

resource "azurerm_network_security_rule" "nsr1" {
  name                        = "allow_https_inbound"
  resource_group_name         = azurerm_resource_group.rg.name
  priority                    = "1001"
  network_security_group_name = azurerm_network_security_group.nsg1.name
  protocol                    = "Tcp"
  access                      = "Allow"
  direction                   = "Inbound"
  source_address_prefix       = "10.0.0.0/26"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  depends_on                  = [azurerm_network_security_group.nsg1]
}

# New resources for App Service
resource "azurerm_app_service_plan" "asp" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app" {
  name                = "${var.prefix}-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  site_config {
    always_on = true
  }
}