module "dates_collector_lambda" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "dates_collector${var.env}"
  description   = "Creates an SQS message with date for each day of previous month"
  handler       = "dates_collector.lambda_handler"
  runtime       = "python3.7"
  timeout       = 900

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/dates_collector"
  memory_size = "500"

  // Attach a policy.

  policy        = {json =data.aws_iam_policy_document.dates_collector_policy.json}

  // Add environment variables.
  environment = {
    variables = {
      QUEUE_URL = aws_sqs_queue.azure_collector_que.id
    }
  }
  tags = {
    "Team" = "FinOps"
  }
}

data "aws_iam_policy_document" "dates_collector_policy" {
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

resource "aws_lambda_permission" "allow_cloudwatch_dates_collector" {
  count         = var.trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.dates_collector_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.dates_collector_cloudwatch_rule[0].arn

  depends_on = [module.dates_collector_lambda]
}

resource "aws_cloudwatch_event_rule" "dates_collector_cloudwatch_rule" {
  count               = var.trigger_count
  name                = "${module.dates_collector_lambda.function_name}_lambda_trigger"
  schedule_expression = var.dates_collector_cron
}

resource "aws_cloudwatch_event_target" "dates_collector_lambda" {
  count     = var.trigger_count
  rule      = aws_cloudwatch_event_rule.dates_collector_cloudwatch_rule[0].name
  target_id = "${module.dates_collector_lambda.function_name}_lambda_target"
  arn       = module.dates_collector_lambda.function_arn
}

resource "aws_cloudwatch_metric_alarm" "dates_collector_lambda_function_error_alarm" {
  alarm_name                = "${module.dates_collector_lambda.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.dates_collector_lambda.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.dates_collector_lambda.function_name
  }
  # alarm_actions = ["${aws_sns_topic.penny.arn}"]
}

