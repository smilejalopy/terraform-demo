terraform {

  # required_version = ">=1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.7.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "terraformwsstatewai"
    container_name = "tfworkshop"
    key = "tfworkshop.tfstate"
    
  }

}
provider "azurerm" {
  features {}
}

# provider "azurerm" {
#   skip_provider_registration = true
#   alias           = "connectivity"
#   features {}
# }

# provider "azurerm" {
#   skip_provider_registration = true
#   alias           = "management"
#   features {}
# }

# provider "azurerm" {
#   skip_provider_registration = true
#   alias           = "identity"
#   features {}
# }



terraform {
 
}