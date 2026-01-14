output "student_credentials" {
  description = "Student usernames and passwords"
  value = {
    for idx, student in var.students : student.name => {
      username          = azuread_user.student_user[idx].user_principal_name
      password          = random_password.student_password[idx].result
      resource_group    = azurerm_resource_group.student_rg[idx].name
      storage_account   = azurerm_storage_account.student_sa[idx].name
    }
  }
  sensitive = true
}

output "student_info" {
  description = "Student resource information (non-sensitive)"
  value = {
    for idx, student in var.students : student.name => {
      username          = azuread_user.student_user[idx].user_principal_name
      resource_group    = azurerm_resource_group.student_rg[idx].name
      storage_account   = azurerm_storage_account.student_sa[idx].name
    }
  }
}
