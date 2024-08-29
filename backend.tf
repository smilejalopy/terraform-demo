
terraform {
  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "terraformwsstatewai"
    container_name = "tfworkshop"
    key = "tfworkshop.tfstate"
    
  }
}