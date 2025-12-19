terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0, < 4.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.0, < 2.0.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "storageoncloud01"
    container_name       = "tfstate"
    key                  = "azure-networking.tfstate"
  }
}

provider "azurerm" {
  features {}
}
