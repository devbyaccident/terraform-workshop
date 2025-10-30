# variables.tf
variable "student_alias" {
  description = "Your student alias"
}

variable "prefix" {
  description = "The prefix for the storage container"
  default     = "default"
}