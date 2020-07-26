#Athena createion Lambda

data "archive_file" "accounts_collector" {
  type        = "zip"
  source_file = "${path.module}/source/accounts_collector.py"
  output_path = "${path.module}/output/accounts_collector.zip"
}

resource "aws_lambda_function" "accounts_collector" {
  filename         = "${path.module}/output/accounts_collector.zip"
  function_name    = "account_collector${var.env}"
  role             = aws_iam_role.iam_role_for_athena.arn
  handler          = "accounts_collector.lambda_handler"
  source_code_hash = data.archive_file.accounts_collector.output_base64sha256
  runtime          = "python3.6"
  memory_size      = "512"
  timeout          = "150"
  description      = "gathers org data and places in sqs"

  environment {
    variables = {
      TA_QUE_URL = aws_sqs_queue.ta_account_que.id
      CO_QUE_URL = aws_sqs_queue.co_account_que.id
    }
  }

  tags = {
    "Team" = "FinOps"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_accounts_collector" {
  count         = var.account_collector_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.accounts_collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.accounts_collector_cloudwatch_rule[0].arn

  depends_on = [aws_lambda_function.accounts_collector]
}

resource "aws_cloudwatch_event_rule" "accounts_collector_cloudwatch_rule" {
  count               = var.account_collector_trigger_count
  name                = "${aws_lambda_function.accounts_collector.function_name}_trigger"
  schedule_expression = var.first_of_the_month_cron
}

resource "aws_cloudwatch_event_target" "accounts_collector_lambda" {
  count     = var.account_collector_trigger_count
  rule      = aws_cloudwatch_event_rule.accounts_collector_cloudwatch_rule[0].name
  target_id = "${aws_lambda_function.accounts_collector.function_name}_target"
  arn       = aws_lambda_function.accounts_collector.arn
}

resource "aws_cloudwatch_metric_alarm" "account_collector_lambda_function_error_alarm" {
  alarm_name                = "${aws_lambda_function.accounts_collector.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${aws_lambda_function.accounts_collector.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.accounts_collector.function_name
  }
  # alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

