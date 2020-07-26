module "lambda_ri_purchases" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "ri_purchases${var.env}"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 600

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/ri_purchases"
  memory_size = "600"

  // Attach a policy.

  policy        = { json = data.aws_iam_policy_document.ri_purchases_policy.json}


  // Add environment variables.
  environment = {
    variables = {
      BUCKET_NAME  = aws_s3_bucket.s3_bucket.id
      SENDEREMAIL  = var.sender_email
      RECIVEREMAIL = var.reciver_email
      REGION       = var.region
    }
  }
  tags = {
    "Team" = "FinOps"
  }
}

data "aws_iam_policy_document" "ri_purchases_policy" {
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
      "ec2:*",
      "rds:*",
      "ce:*",
      "ce:GetReservationUtilization",
      "glue:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_ri_purchases" {
  count         = var.ri_purchase_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_ri_purchases.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ri_purchases_cloudwatch_rule[0].arn

  depends_on = [module.lambda_ri_purchases]
}

resource "aws_cloudwatch_event_rule" "ri_purchases_cloudwatch_rule" {
  count               = var.ri_purchase_trigger_count
  name                = "${module.lambda_ri_purchases.function_name}_lambda_trigger"
  schedule_expression = var.ri_purchases_cron
}

resource "aws_cloudwatch_event_target" "ri_purchases_lambda" {
  count     = var.ri_purchase_trigger_count
  rule      = aws_cloudwatch_event_rule.ri_purchases_cloudwatch_rule[0].name
  target_id = "${module.lambda_ri_purchases.function_name}_lambda_target"
  arn       = module.lambda_ri_purchases.function_arn
}

resource "aws_cloudwatch_metric_alarm" "ri_purchase_billing_lambda_function_error_alarm" {
  alarm_name                = "${module.lambda_ri_purchases.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.lambda_ri_purchases.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_ri_purchases.function_name
  }
  #alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

