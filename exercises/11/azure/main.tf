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

# TODO: This exercise deploys microservices using ASGs and ALBs on AWS. Manual conversion is required:
# - Replace modules/microservice with VM Scale Sets (azurerm_linux_virtual_machine_scale_set) or AKS.
# - Replace ALB/ALB Listeners with azurerm_application_gateway or azurerm_load_balancer.
# Module calls are left in place for reference but will not work on Azure until converted.

module "frontend" {
  source = "./microservice"

  # NOTE: module parameters remain but the module itself requires conversion to Azure resources.
  name             = "frontend"
  min_size         = 1
  max_size         = 2
  key_name         = var.key_name
  user_data_script = file("user-data/user-data-frontend.sh")
  server_text      = var.frontend_server_text
  student_alias    = var.student_alias
  is_internal_alb  = false
  location         = var.location

  backend_url = module.backend.url
}

module "backend" {
  source = "./microservice"

  name             = "backend"
  min_size         = 1
  max_size         = 3
  key_name         = var.key_name
  user_data_script = file("user-data/user-data-backend.sh")
  server_text      = var.backend_server_text
  student_alias    = var.student_alias
  is_internal_alb  = true
  location         = var.location
}
