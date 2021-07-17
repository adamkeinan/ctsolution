#Set S3 backend for persisting TF state file remotely, ensure bucket already exits
# And that AWS user being used by TF has read/write perms
terraform {
  required_version = ">=0.14.0"
  required_providers {
    aws = ">=3.1.0"
  }
  backend "s3" {
    region  = "eu-west-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "eksbackend"
  }
}
