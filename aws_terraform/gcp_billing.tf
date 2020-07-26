module "lambda_gcp_billing" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "gcp_billing"
  description   = "Collects gcp billing for projects from BQ"
  handler       = "gcp_billing.lambda_handler"
  runtime       = "python3.6"
  timeout       = 600

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/gcp_billing"
  memory_size = "600"

  // Attach a policy.
  policy        = {json = data.aws_iam_policy_document.gcp_billing_policy.json}


  // Add environment variables.
  environment = {
    variables = {
      API             = data.aws_ssm_parameter.big_query_api.value
      S3_BUCKET_NAME  = aws_s3_bucket.s3_bucket.id
      BILLING_PROJECT = var.gcp_billing_project
      QUERY           = data.template_file.gcp_billing_export_query.rendered
    }
  }
  tags = {
    Project = "Penny"
    Team    = "FinOps"
  }
}

data "template_file" "gcp_billing_export_query" {
  template = file("${path.module}/big_query_queries/gcp_billing_export.sql")

  vars = {
    gcp_billing_export = var.gcp_billing_export
  }
}

data "aws_iam_policy_document" "gcp_billing_policy" {
  statement {
    actions = [
      "aws-portal:*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_gcp_billing" {
  count         = var.gcp_billing_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_gcp_billing.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.gcp_billing_cloudwatch_rule[0].arn

  depends_on = [module.lambda_gcp_billing]
}

resource "aws_cloudwatch_event_rule" "gcp_billing_cloudwatch_rule" {
  count               = var.gcp_billing_trigger_count
  name                = "gcp_billing_lambda_trigger"
  schedule_expression = var.gcp_billing_cron
}

resource "aws_cloudwatch_event_target" "gcp_billing_lambda" {
  count     = var.gcp_billing_trigger_count
  rule      = aws_cloudwatch_event_rule.gcp_billing_cloudwatch_rule[0].name
  target_id = "gcp_billing_lambda"
  arn       = module.lambda_gcp_billing.function_arn
}

//cloudwatch metric alarm triggered if error during lambda invocation. If alarm triggered an alarm notification is sent via an SNS topic

resource "aws_cloudwatch_metric_alarm" "gcp_billing_lambda_function_error_alarm" {
  alarm_name                = "${module.lambda_gcp_billing.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.lambda_gcp_billing.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_gcp_billing.function_name
  }
  #alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

