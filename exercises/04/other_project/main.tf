# main.tf

# Declare the provider being used, in this case it's AWS.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# declare a resource block so we can create something.
resource "aws_s3_bucket" "user_bucket" {
  bucket_prefix = var.student_name
  versioning {
    enabled = true
  }
}

