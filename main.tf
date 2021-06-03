# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  backend "remote" {
    organization = "codehub-spanos"

    workspaces {
      name = "team5-cicd"
    }
  }
}

provider "azurerm" {
  features {}
  # This is used for creating a service principal connection with Azure. To connect with azure CLI simply comment out the following four lines
  # Owner
  subscription_id = var.subscription_id
  client_id       = var.client_appId
  client_secret   = var.client_password
  tenant_id       = var.tenant_id
}

# Create a resource group for development environment
resource "azurerm_resource_group" "rg_cicd" {
  name     = "${var.prefix}-resource-group"
  location = var.location
  tags     = var.tags
}

module "virtual_machines" {
    source = "./modules/virtual_machines"
    location = var.location
    prefix = var.prefix
    rg = azurerm_resource_group.rg_cicd
    admin_username = var.admin_username
}