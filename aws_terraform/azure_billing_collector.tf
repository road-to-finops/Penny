module "azure_billing_collector_lambda" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "azure_billing_collector${var.env}"
  description   = "Deployment deploy status task"
  handler       = "azure.lambda_handler"
  runtime       = "python3.6"
  timeout       = 900

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/azure_billing_collector"
  memory_size = "3000"

  // Attach a policy.
  policy        = {json = data.aws_iam_policy_document.azure_billing_collector_policy.json}

  // Add environment variables.
  environment = {
    variables = {
      ENROL       = data.aws_ssm_parameter.azure_enrolmentid.value
      API         = data.aws_ssm_parameter.azure_api.value
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
    }
  }
  tags = {
    "Team" = "FinOps"
  }
}


data "aws_iam_policy_document" "azure_billing_collector_policy" {
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
      "s3:*",
      "glue:*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      aws_sqs_queue.azure_collector_que.arn,
    ]
  }
}

resource "aws_cloudwatch_metric_alarm" "azure_billing_collector_lambda_function_error_alarm" {
  alarm_name                = "${module.azure_billing_collector_lambda.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.azure_billing_collector_lambda.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.azure_billing_collector_lambda.function_name
  }
  #alarm_actions = ["${aws_sns_topic.penny.arn}"]
}

