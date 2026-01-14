# variables.tf

# Declare a variable so we can use it.
variable "student_alias" {
  description = "Your student alias"
}

output "other_project_bucket" {
  value = data.terraform_remote_state.other_project.outputs.sc_name
}