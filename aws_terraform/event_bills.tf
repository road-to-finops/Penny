#Azure
/*module "azure_event" {
  source                  = "./module/events"
  name                    = "azure_billing"
  cron                    = var.azure_billing_report_cron
  lambda_arn              = module.athena_query.function_arn
  lambda_name             = module.athena_query.function_name
  emails                  = var.azure_billing_lambda_emails
  env                     = var.env
  s3_bucket_id            = aws_s3_bucket.s3_bucket.id
  query_name              = "azure_billing"
  query_location          = file("${path.module}/Athena_Queries/azure_billing.sql")
  recharger               = "True"
  query_type              = "finops_bill"
  enable_cloudwatch_event = var.enable_cloudwatch_event
}
*/
