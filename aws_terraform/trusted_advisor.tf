module "lambda_trusted_advisor" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "trusted_advisor${var.env}"
  description   = "trusted advisor collector"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 100

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/trusted_advisor"
  memory_size = "2000"

  // Attach a policy.

  policy        = {json = data.aws_iam_policy_document.trusted_advisor_policy.json}

  // Add environment variables.
  environment = {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      REGION      = var.region
      QUE_URL     = aws_sqs_queue.ta_account_que.id
    }
  }
}

data "aws_iam_policy_document" "trusted_advisor_policy" {
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
      "trusted:*",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_trusted_advisor" {
  count         = var.ta_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_trusted_advisor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trusted_advisor_cloudwatch_rule[0].arn

  depends_on = [module.lambda_trusted_advisor]
}

resource "aws_cloudwatch_event_rule" "trusted_advisor_cloudwatch_rule" {
  count               = var.ta_trigger_count
  name                = "trusted_advisor_lambda_trigger"
  schedule_expression = var.first_of_the_month_cron
}

resource "aws_cloudwatch_event_target" "trusted_advisor_lambda" {
  count     = var.ta_trigger_count
  rule      = aws_cloudwatch_event_rule.trusted_advisor_cloudwatch_rule[0].name
  target_id = "trusted_advisor_lambda"
  arn       = module.lambda_trusted_advisor.function_arn
}

resource "aws_cloudwatch_metric_alarm" "trusted_advisor_lambda_function_error_alarm" {
  alarm_name                = "${module.lambda_trusted_advisor.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.lambda_trusted_advisor.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_trusted_advisor.function_name
  }
  # alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

