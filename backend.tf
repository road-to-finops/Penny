provider "aws" {
  profile = "personal_dev"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket  = "steph-dev-account-bucket"
    key     = "state/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    profile = "personal_dev"
  }
}
