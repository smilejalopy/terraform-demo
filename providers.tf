terraform {

  # required_version = ">=1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  backend "azurerm" {
    resource_group_name = "Terraform"
    storage_account_name = "anuterraformstatew"
    container_name = "tfworkshop"
    key = "tfworkshop.tfstate2"
    use_azuread_auth = true
    use_oidc = true
  }

}
provider "azurerm" {
  features {}
  use_oidc = true
}



provider "azurerm" {
  skip_provider_registration = true
  alias           = "connectivity"
  features {}
}

provider "azurerm" {
  skip_provider_registration = true
  alias           = "management"
  features {}
}

provider "azurerm" {
  skip_provider_registration = true
  alias           = "identity"
  features {}
}



