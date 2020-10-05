#GCP
module "gcp_test_report" {
  source         = "module/events"
  name           = "gcp_test_report"
  cron           = "${var.gcp_billing_cron}"
  lambda_arn     = "${module.lambda_big_query.function_arn}"
  lambda_name    = "${module.lambda_big_query.function_name}"
  emails         = "${var.finops_emails}"
  env            = "${var.env}"
  icm_env        = "${var.icm_env}"
  s3_bucket_id   = "${aws_s3_bucket.s3_bucket.id}"
  query_name     = "gcp_test_report"
  query_location = "${file("${path.module}/BigQuery_Queries/gcp_billing_bq.sql")}"
  query_type     = "finops_report"
}
