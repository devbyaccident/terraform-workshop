# variables.tf

# Declare a variable so we can use it.
variable "region" {
  default = "eastus2"
}

variable "student_name" {
  default = "student-"
}

output "sc_name" {
  value = azurerm_storage_container.container.id
}