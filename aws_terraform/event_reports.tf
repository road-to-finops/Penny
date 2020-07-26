/*
module "fof_create_table" {
  source         = "module/events"
  name           = "fof_create_table"
  cron           = "${var.aws_report_cron}"
  lambda_arn     = "${module.athena_query.function_arn}"
  lambda_name    = "${module.athena_query.function_name}"
  emails         = "${var.reciver_email}"
  env            = "${var.env}"
  s3_bucket_id   = "${aws_s3_bucket.s3_bucket.id}"
  query_name     = "fof_create_table"
  query_location = "${file("${path.module}/athena_tables/fof_table.sql")}"
  query_type     = "finops_report"
  database       = "${var.athena_db_name}"
}

module "azure_create_table" {
  source         = "module/events"
  name           = "azure_create_table"
  cron           = "${var.aws_report_cron}"
  lambda_arn     = "${module.athena_query.function_arn}"
  lambda_name    = "${module.athena_query.function_name}"
  emails         = "${var.reciver_email}"
  env            = "${var.env}"
  s3_bucket_id   = "${aws_s3_bucket.s3_bucket.id}"
  query_name     = "azure_create_table"
  query_location = "${file("${path.module}/athena_tables/azure_table.sql")}"
  query_type     = "finops_report"
  database       = "${var.athena_db_name}"
}
*/
