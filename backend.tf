terraform {
  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "terraformworkshopstate"
    container_name = "tfworkshop"
    key = "tfworkshop.tfstate"
  }
}