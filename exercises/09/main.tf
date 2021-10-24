# main.tf

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
  region = "us-east-1"
}

# declare a resource block so we can create something.
resource "aws_s3_bucket_object" "dynamic_file" {
  count   = var.object_count
  bucket  = "blackden-di-${var.student_alias}"
  key     = "dynamic-file-${count.index}"
  content = "dynamic-file at index ${count.index}"
}

resource "aws_s3_bucket_object" "optional_file" {
  count   = var.include_optional_file ? 1 : 0
  bucket  = "blackden-di-${var.student_alias}"
  key     = "optional-file"
  content = "optional-file"
}

