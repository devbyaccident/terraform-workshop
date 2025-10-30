terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_storage_container" "container" {
  name                  = "beepboop"
  storage_account_name  = "greatjay"
  container_access_type = "private"
}