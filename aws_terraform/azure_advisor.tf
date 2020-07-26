module "lambda_azure_advisor" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "azure_advisor${var.env}"
  description   = "Deployment deploy status task"
  handler       = "azure_advisor.lambda_handler"
  runtime       = "python3.6"
  timeout       = 600

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/azure_advisor"
  memory_size = "600"

  // Attach a policy.

  policy        = {json = data.aws_iam_policy_document.azure_advisor_policy.json}


  // Add environment variables.
  environment = {
    variables = {
      PASSWORD    = var.azure_password
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      USERNAME    = var.azure_username
      TENANT      = var.azure_tenant
      CLIENT_ID   = var.azure_client_id
    }
  }
  tags = {
    "Team" = "FinOps"
  }
}

data "aws_iam_policy_document" "azure_advisor_policy" {
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
      "glue:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_azure_advisor" {
  count         = var.azure_advisor_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_azure_advisor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.azure_advisor_cloudwatch_rule[0].arn

  depends_on = [module.lambda_azure_advisor]
}

resource "aws_cloudwatch_event_rule" "azure_advisor_cloudwatch_rule" {
  count               = var.azure_advisor_trigger_count
  name                = "${module.lambda_azure_advisor.function_name}_lambda_trigger"
  schedule_expression = var.collector_cron
}

resource "aws_cloudwatch_event_target" "azure_advisor_lambda" {
  count     = var.azure_advisor_trigger_count
  rule      = aws_cloudwatch_event_rule.azure_advisor_cloudwatch_rule[0].name
  target_id = "${module.lambda_azure_advisor.function_name}_target"
  arn       = module.lambda_azure_advisor.function_arn
}

resource "aws_cloudwatch_metric_alarm" "azure_advisor_billing_lambda_function_error_alarm" {
  alarm_name                = "${module.lambda_azure_advisor.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.lambda_azure_advisor.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_azure_advisor.function_name
  }
}

