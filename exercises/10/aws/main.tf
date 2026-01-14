# Declare the provider being used, in this case it's AWS.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

# This provider supports setting the provider version, AWS credentials as well as the region.
# It can also pull credentials and the region to use from environment variables, which we have set, so we'll use those
provider "aws" {
  region = "us-east-1"
}

# The part that ensures that the state for this infrastructure will be centrally stored, in S3
terraform {
  backend "s3" {
    # Don't add the bucket name here, you'll be prompted for it when you run `terraform apply`
    region = "us-east-1"
  }
}

# declare a resource block so we can create something.
resource "aws_s3_object" "user_student_alias_object" {
  bucket  = "terraform-intro-di-${var.student_alias}"
  key     = "student.alias"
  content = "This bucket is reserved for ${var.student_alias}"
}
