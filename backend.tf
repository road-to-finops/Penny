provider "aws" {
  profile = "<personal>"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket  = "<account-bucket>"
    key     = "statefile/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    profile = "<personal>"
  }
}
