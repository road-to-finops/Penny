resource "aws_cloudwatch_event_rule" "finops" {
  #count               = "${terraform.workspace == "prod" ? 1 : 0}"
  name                = "${var.query_type}_${var.name}${var.env}"
  schedule_expression = var.cron                            #cron(07 1 * ? * *)
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  #count     = "${terraform.workspace == "prod" ? 1 : 0}"
  target_id = "${var.name}${var.env}"
  rule      = aws_cloudwatch_event_rule.finops.name
  arn       = var.lambda_arn

  input = "{\"Query\":\"${data.template_file.sql.rendered}\", \"Email\":\"${var.emails}\", \"Database\": \"${var.database}${var.env}\", \"Query_Name\":\"${var.query_name}\", \"Bucket\":\"${var.s3_bucket_id}\", \"Env\":\"${var.env}\", \"GCP_Project\":\"${var.gcp_project}\", \"Query_Type\":\"${var.query_type}}"
}

data "template_file" "sql" {
  template = var.query_location

  vars = {
    Database_Value = "${var.database}${var.env}"
    account_id     = data.aws_caller_identity.current.account_id
  }
}
