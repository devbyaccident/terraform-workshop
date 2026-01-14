# main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_storage_blob" "student_alias_blob" {
  name                   = "student.alias"
  storage_account_name   = var.student_alias
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "This container is reserved for ${var.student_alias}"
}
