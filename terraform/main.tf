data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_key_vault" "keyvaultexample" {
  name                       = "examplekeyvault"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"
}

resource "azurerm_monitor_diagnostic_setting" "keyvaultdiagexample" {
  name               = "diag-keyvaultexample"
  target_resource_id = azurerm_key_vault.keyvaultexample.id
  storage_account_id = azurerm_storage_account.saexample.id

  log {
    category = "AuditEvent"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_storage_account" "saexample" {
  name                     = "stastorageaccountname"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_diagnostic_setting" "instance" {
  name                           = "diag-${azurerm_storage_account.saexample.name}"
  target_resource_id             = azurerm_storage_account.saexample.id

  dynamic "log" {
    for_each = var.diag_settings
    content {
      category = log.value.category
      enabled  = true

      retention_policy {
        enabled = true
        days    = "30"
      }
    }
  }

  metric {
    category = "Requests"
    enabled  = true

    retention_policy {
      enabled = true
      days    = "30"
    }
  }

}


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.63"
    }
  }
}
provider "azurerm" {
  features {}
}
