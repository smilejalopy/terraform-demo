variable "client_id" {}
variable "subscription_id" {}
variable "tenant_id" {}

terraform {
  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "terraformwsstatewai"
    container_name = "tfworkshop"
    key = "tfworkshop.tfstate"
    use_oidc             = true # To use OIDC to authenticate to the backend
    client_id            = var.client_id 
    subscription_id      = var.subscription_id
    tenant_id            = var.tenant_id
    
  }
}