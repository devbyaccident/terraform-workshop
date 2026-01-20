# main.tf

provider "azurerm" {
  features {}
}

data "azurerm_location" "this" {
  location = "East US 2"
}

output "zones" {
  value = data.azurerm_location.this.zone_mappings
}

output "current_location" {
  value = data.azurerm_location.this.location
}