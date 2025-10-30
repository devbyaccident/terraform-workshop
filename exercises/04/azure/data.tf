data "terraform_remote_state" "other_project" {
  backend = "local"
  config = {
    path = "other_project/terraform.tfstate"
  }
}
