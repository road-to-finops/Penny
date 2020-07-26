module "lambda_big_query" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "big_query${var.env}"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 600

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/big_query"
  memory_size = "600"

  // Attach a policy.

  policy        = {json = data.aws_iam_policy_document.big_query_policy.json}


  // Add environment variables.
  environment = {
    variables = {
      API          = data.aws_ssm_parameter.big_query_api.value
      REGION       = var.region
      SENDEREMAIL  = var.sender_email
      RECIVEREMAIL = var.reciver_email
    }
  }
  tags = {
    "Project" = "Penny"
    "Team"    = "FinOps"
  }
}


data "aws_iam_policy_document" "big_query_policy" {
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
      "ses:SendRawEmail",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_big_query" {
  count         = var.gcp_billing_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_big_query.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.big_query_cloudwatch_rule[0].arn

  depends_on = [module.lambda_big_query]
}

resource "aws_cloudwatch_event_rule" "big_query_cloudwatch_rule" {
  count               = var.gcp_billing_trigger_count
  name                = "${module.lambda_big_query.function_name}_lambda_trigger"
  schedule_expression = var.gcp_billing_cron
}

resource "aws_cloudwatch_event_target" "big_query_lambda" {
  count     = var.gcp_billing_trigger_count
  rule      = aws_cloudwatch_event_rule.big_query_cloudwatch_rule[0].name
  target_id = "${module.lambda_big_query.function_name}_lambda_target"
  arn       = module.lambda_big_query.function_arn
}

//cloudwatch metric alarm triggered if error during lambda invocation. If alarm triggered an alarm notification is sent via an SNS topic

resource "aws_cloudwatch_metric_alarm" "big_query_lambda_function_error_alarm" {
  alarm_name                = "${module.lambda_big_query.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.lambda_big_query.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_big_query.function_name
  }
  # alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

