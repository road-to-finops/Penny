/*module "athena_query_lambda" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v0.11.3"

  function_name = "athena_query_lambda${var.env}
  description   = "Deployment deploy status task"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/athena_query_lambda"

  // Attach a policy.

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.athena_policy.json}"
  // Add a dead letter queue.
  attach_dead_letter_config = false
  // Deploy into a VPC.
  attach_vpc_config = false
  // Add environment variables.
  environment {
    variables {
      BUCKET_LOCATION = "s3://${aws_s3_bucket.s3_bucket.id}/athena/test"
      DATABASE        = "${var.athena_db_name}"
      TABLE           = "${var.athena_table_name}"
      REGION          = "${var.region}"
      QUERY           = "${data.template_file.sql.rendered}"
      QUERY_NAME      = "Athena_test"
      EMAILS          = "stephanie.gooch@kpmg.co.uk"
    }
  }
}


data "template_file" "sql" {
  template = "${file("${path.module}/source/athena_query_lambda/query.sql")}"
  vars = {
    Database_Value = "${var.athena_db_name}"
    Tabel_Value = "${var.athena_table_name}"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_athena_query_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.athena_query_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.athena_query_lambda_cloudwatch_rule.arn}"

  depends_on = ["module.athena_query_lambda"]
}

resource "aws_cloudwatch_event_rule" "athena_query_lambda_cloudwatch_rule" {
  name                = "athena_query_lambda_trigger"
  schedule_expression = "${var.adp_account_cron}"
}

resource "aws_cloudwatch_event_target" "athena_query_lambda" {
  rule      = "${aws_cloudwatch_event_rule.athena_query_lambda_cloudwatch_rule.name}"
  target_id = "athena_lambda_target"
  arn       = "${module.athena_query_lambda.function_arn}"
}
*/

