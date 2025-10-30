variable "students" {
  type        = list(map(string))
  description = "list of students and associated info"
}

variable "pgp_key" {
  description = "base64 encoded gpg key for use in generating user passwords"
}

variable "location" {
  default = "eastus2"
}
