terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Per-student resource groups, storage accounts, users and RBAC assignments

# Create a resource group per student
resource "azurerm_resource_group" "student_rg" {
  count    = length(var.students)
  name     = "rg-student-${var.students[count.index].name}"
  location = var.location
}

# Create a storage account per student in their resource group
resource "azurerm_storage_account" "student_sa" {
  count                    = length(var.students)
  name                     = "${var.students[count.index].name}"
  resource_group_name      = azurerm_resource_group.student_rg[count.index].name
  location                 = azurerm_resource_group.student_rg[count.index].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

# Create a container in each storage account
resource "azurerm_storage_container" "student_container" {
  count                 = length(var.students)
  name                  = "data"
  storage_account_name  = azurerm_storage_account.student_sa[count.index].name
  container_access_type = "private"
}

# Generate a random password for each student
resource "random_password" "student_password" {
  count   = length(var.students)
  length  = 16
  special = false
}

# Create Azure AD user for each student
resource "azuread_user" "student_user" {
  count               = length(var.students)
  user_principal_name = "${var.students[count.index].name}@${data.azuread_domains.default.domains[0].domain_name}"
  display_name        = var.students[count.index].name
  password            = random_password.student_password[count.index].result
  force_password_change = true
}

# Assign Storage Blob Data Contributor role to each student for their storage account
resource "azurerm_role_assignment" "student_storage_contributor" {
  count                = length(var.students)
  scope                = azurerm_storage_account.student_sa[count.index].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_user.student_user[count.index].object_id
}

# Assign Contributor role to each student for their resource group
resource "azurerm_role_assignment" "student_rg_contributor" {
  count                = length(var.students)
  scope                = azurerm_resource_group.student_rg[count.index].id
  role_definition_name = "Contributor"
  principal_id         = azuread_user.student_user[count.index].object_id
}

# Assign Compute Fleet Contributor role to each student for their storage account
resource "azurerm_role_assignment" "student_fleet_contributor" {
  count                = length(var.students)
  scope                = azurerm_storage_account.student_sa[count.index].id
  role_definition_name = "Compute Fleet Contributor"
  principal_id         = azuread_user.student_user[count.index].object_id
}

# Data source to get the default domain
data "azuread_domains" "default" {
  only_initial = true
}
