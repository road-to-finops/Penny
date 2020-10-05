variable "sender_email" {
  default = "example@email.com"
}

variable "reciver_email" {
  default = "example@email.com"
}

variable "bucket_name" {
  default = "buisnesspennybucket"
}

variable "region" {
  default = "eu-west-1"
}

variable "aws_report_cron" {
  default = "cron(07 12 * ? * *)"
}

variable "first_of_the_month_cron" {
  default = "cron(16 1 * ? * *)"
}

variable "ri_payback_cron" {
  default = "cron(07 1 * ? * *)"
}

variable "ri_reccomendation_cron" {
  default = "cron(07 1 * ? * *)"
}

variable "ri_purchases_cron" {
  default = "cron(07 1 * ? * *)"
}

variable "fof_cron" {
  default = "cron(07 1 * ? * *)"
}

variable "service_dynamo_cron" {
  default = "cron(07 1 ? * MON *)"
}

variable "dates_collector_cron" {
  default = "cron(00 10 2 * ? *)"
}

variable "athena_db_name" {
  default = "athenacurcfn_mybillingreport"
}

variable "athena_table_name" {
  default = "mybillingreport"
}

variable "pricing_db_name" {
  default = "pricing"
}

variable "azure_billing_cron" {
  default = "cron(07 2 * ? * *)"
}

variable "gcp_billing_cron" {
  default = "cron(10 * * ? * *)"
}

variable "azure_advisor_cron" {
  default = "cron(02 1 * ? * *)"
}

variable "azure_billing_report_cron" {
  default = "cron(30 10 2 * ? *)"
}

variable "collector_cron" {
  default = "cron(07 1 * ? * *)"
}

#######need to update
variable "user_arn" {
  default = ""
}

#Azure Advisor

variable "azure_username" {
  default = ""
}

variable "azure_tenant" {
  default = ""
}

variable "azure_client_id" {
  default = ""
}

variable "azure_password" {
  default = ""
}

variable "gcp_billing_project" {
  default = ""
}

variable "gcp_billing_export" {
  default = ""
}

variable "env" {
  default = ""
}

# cloudwatch metric alarm 
variable "cloudwatch_metric_alarm_statistic" {
  default = "Minimum"
}

variable "cloudwatch_metric_alarm_threshold" {
  default = "1" //1 error
}

variable "cloudwatch_metric_alarm_period" {
  default = "10800" //3 hours in secs
}

variable "cloudwatch_metric_alarm_comparison_operator" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "cloudwatch_metric_alarm_metric_name" {
  default = "Errors"
}

variable "cloudwatch_metric_alarm_evaulation_periods" {
  default = "1"
}

# BigQuery
variable "bqapi" {
  default = ""
}

# trigger variable
variable "trigger_count" {
  default = "0"
}

