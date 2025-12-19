terraform {
  required_version = "1.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "2.8.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "0.3.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {}
}
