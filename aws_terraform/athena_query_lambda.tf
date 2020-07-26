module "athena_query" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "athena_query${var.env}"
  description   = "Deployment deploy status task"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 500

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/athena_query_lambda"
  memory_size = "600"

  // Attach a policy.
  policy        = { json = data.aws_iam_policy_document.athena_policy.json}

  // Add environment variables.
  environment = {
    variables = {
      REGION       = var.region
      SENDEREMAIL  = var.sender_email
      RECIVEREMAIL = var.reciver_email
    }
  }
  tags = {
    "Team" = "FinOps"
  }
}

resource "aws_cloudwatch_metric_alarm" "athena_billing_lambda_function_error_alarm" {
  alarm_name                = "${module.athena_query.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.athena_query.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.athena_query.function_name
  }
  # alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

resource "aws_lambda_permission" "allow_cloudwatch_permisson_bill" {
  statement_id  = "AllowExecutionFromCloudWatch_Billing"
  action        = "lambda:InvokeFunction"
  function_name = module.athena_query.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/finops_bill_*"
}

resource "aws_lambda_permission" "allow_cloudwatch_permisson_report" {
  statement_id  = "AllowExecutionFromCloudWatch_Reporting"
  action        = "lambda:InvokeFunction"
  function_name = module.athena_query.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/finops_report_*"
}

