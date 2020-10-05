variable "name" {}

variable "cron" {}
variable "lambda_arn" {}

variable "lambda_name" {}

variable "emails" {}

variable "env" {}

variable "s3_bucket_id" {}

variable "query_name" {}
variable "query_location" {}

variable "team" {
  default = ""
}

variable "recharger" {
  default = "False"
}

variable "query_type" {
  default = ""
}

variable "icm_env" {
  default = ""
}

variable "database" {}

variable "gcp_project" {
  default = ""
}

data "aws_caller_identity" "current" {}
