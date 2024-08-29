variable "client_id" {}
variable "subscription_id" {}
variable "tenant_id" {}

terraform {
  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "terraformwsstatewai"
    container_name = "tfworkshop"
    key = "tfworkshop.tfstate"
    use_oidc             = true
  }
}