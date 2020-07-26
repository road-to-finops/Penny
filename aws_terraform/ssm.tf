
# connected to azure_billing_collector.tf
data "aws_ssm_parameter" "azure_api" {
  name = "/penny/azure/azure_api"
}

# connected to azure_billing_collector.tf
data "aws_ssm_parameter" "azure_enrolmentid" {
  name = "/penny/azure/azure_enrolmentid"
}

# connected to big_query_lambda.tf
data "aws_ssm_parameter" "big_query_api" {
  name = "/penny/big_query/big_query_api"
}
