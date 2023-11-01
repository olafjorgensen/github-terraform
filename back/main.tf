terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.78.0"
    }
  }

backend "azurerm" {
  resource_group_name = "rg-back-tfstate"
  storage_account_name = "sabntfsmuiivw73tx"
  container_name = "tfstate"
  key = "back.terraform.tfstate"
  
}

}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

resource "random_string" "random_string" {
  length  = 10
  special = false
  upper   = false

}

resource "azurerm_resource_group" "rg_back" {
  name     = var.rg_back_name
  location = var.rg_back_location
}

resource "azurerm_storage_account" "sa_back" {
  name                     = "${lower(var.sa_back_name)}${random_string.random_string.result}"
  resource_group_name      = azurerm_resource_group.rg_back.name
  location                 = azurerm_resource_group.rg_back.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "sc_back" {
  name                  = var.sc_back_name
  storage_account_name  = azurerm_storage_account.sa_back.name
  container_access_type = "private"
}


data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "kv_back" {
  name                        = "${lower(var.kv_back_name)}${random_string.random_string.result}"
  location                    = azurerm_resource_group.rg_back.location
  resource_group_name         = azurerm_resource_group.rg_back.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get","List","Create",
    ]

    secret_permissions = [
      "Get","Set","List",
    ]

    storage_permissions = [
      "Get","Set","List",
    ]
  }
}

resource "azurerm_key_vault_secret" "sa_back_accesskey" {
  name         = var.sa_back_accesskey_name
  value        = azurerm_storage_account.sa_back.primary_access_key
  key_vault_id = azurerm_key_vault.kv_back.id
}