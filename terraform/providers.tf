terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.78.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-back-tfstate"
    storage_account_name = "sabntfsmuiivw73tx"
    container_name       = "tfstate"
    key                  = "rg.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}