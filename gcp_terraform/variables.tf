variable "organization_id" {
  type        = string
  description = "The ID of the Organisation to create."
}

variable "billing_account_id" {
  type        = string
  description = "The Id of the billing account to use for the security projects."
}

variable "salt" {
  type        = string
  description = "The random salt number to apply to projects to form the ID"
}

variable "cost_code" {
  type        = string
  description = "The cost code the security projects should be billed to."
}

variable "log_retention_period" {
  type        = string
  description = "The number of days the logging bucket should retain logs for."
}

variable "billing_services" {

}
