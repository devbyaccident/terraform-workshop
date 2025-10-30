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

resource "azurerm_storage_container" "student_container" {
  name                  = "${var.prefix}-${var.student_alias}"
  storage_account_name  = var.student_alias
  container_access_type = "private"
}