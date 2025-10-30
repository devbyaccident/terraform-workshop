
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
  skip_provider_registration = true
}

resource "azurerm_storage_blob" "dynamic_file" {
  count                  = var.object_count
  name                   = "dynamic-file-${count.index}"
  storage_account_name   = var.student_alias
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "dynamic-file at index ${count.index}"
}

resource "azurerm_storage_blob" "optional_file" {
  count                  = var.include_optional_file ? 1 : 0
  name                   = "optional-file"
  storage_account_name   = var.student_alias
  storage_container_name = "data"
  type                   = "Block"
  source_content         = "optional-file"
}

