terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "student_alias" {
  description = "Your student alias"
}

# We can see this separate project that's just in charge of setting up our state bucket
# One might also just do this manually
resource "aws_s3_bucket" "state_bucket" {
  bucket_prefix = "terraform-intro-di-${var.student_alias}-"
  force_destroy = true
}

output "state_bucket_name" {
  value = aws_s3_bucket.state_bucket.bucket
}
