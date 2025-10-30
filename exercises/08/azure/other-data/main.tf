# main.tf

# Convert this example to use the AzureRM provider and Azure data sources.
# The original AWS example used `aws_ami` and `aws_availability_zones`. Here we
# demonstrate how to query the latest Ubuntu marketplace image and the current
# client/subscription information in Azure.

provider "azurerm" {
  features {}
}

# Query the latest Canonical Ubuntu image from the Azure Marketplace. Update
# `location` to the region you intend to deploy into (for example, "eastus").
data "azurerm_virtual_machine_image" "ubuntu" {
  location  = "eastus"
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}

# Client config provides useful information about the current authenticated
# client (subscription_id, tenant_id, etc.). This is the Azure equivalent of
# some account-level metadata you might inspect in other providers.
data "azurerm_client_config" "current" {}

output "most_recent_ubuntu_image_id" {
  value = data.azurerm_virtual_machine_image.ubuntu.id
}

output "current_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

# Notes:
# - Azure availability zones are a per-location capability; Terraform does not
#   expose a simple `availability_zones` data source like AWS. Instead, you
#   typically check the `location` and consult Azure documentation or use the
#   Azure CLI to inspect zones for a region. For many scenarios you use
#   `data.azurerm_resource_group.<rg>.location` or `azurerm_client_config`.