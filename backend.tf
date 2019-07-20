provider "aws" {
  profile = "<profile>"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket  = "<backend-bucket>"
    key     = "state/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    profile = "<profile>"
  }
}