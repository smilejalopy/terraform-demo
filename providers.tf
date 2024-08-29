terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.74.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
provider "random" {
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