provider "aws" {
  profile = "penny"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket  = "penny-bucket-*account number*"
    key     = "statefile/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    profile = "penny"
  }
}
