# Declare the provider being used, in this case it's AWS.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# This provider supports setting the provider version, AWS credentials as well as the region.
# It can also pull credentials and the region to use from environment variables, which we have set, so we'll use those
provider "aws" {
  region = var.region
}

# The part that ensures that the state for this infrastructure will be centrally stored, in S3
terraform {
  backend "s3" {
    region = var.region # Don't add anything else here, you'll be prompted for the required values when you run terraform apply
  } 
}

# declare a resource block so we can create something.
resource "aws_s3_bucket_object" "user_student_alias_object" {
  bucket  = "terraform-intro-di-${var.student_alias}"
  key     = "student.alias"
  content = "This bucket is reserved for ${var.student_alias}"
}
