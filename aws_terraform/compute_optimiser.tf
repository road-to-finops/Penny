module "lambda_compute_optimiser" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "compute_optimiser${var.env}"
  description   = "compute optimiser collector"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 100

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/compute_optimizer"
  memory_size = "2000"

  // Attach a policy.

  policy        = {json = data.aws_iam_policy_document.compute_optimiser_policy.json}

  // Add environment variables.
  environment = {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      REGION      = var.region
      QUE_URL     = aws_sqs_queue.co_account_que.id
      REGION      = var.region
    }
  }
}

data "aws_iam_policy_document" "compute_optimiser_policy" {
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
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "compute-optimizer:*",
      "EC2:DescribeInstances",
      "cloudwatch:GetMetricData",
      "autoscaling:DescribeAutoScalingGroups",
      "compute-optimizer:UpdateEnrollmentStatus",
      "compute-optimizer:GetAutoScalingGroupRecommendations",
      "compute-optimizer:GetEC2InstanceRecommendations",
      "compute-optimizer:GetEnrollmentStatus",
      "compute-optimizer:GetEC2RecommendationProjectedMetrics",
      "compute-optimizer:GetRecommendationSummaries",
      "organizations:ListAccounts",
      "organizations:DescribeOrganization",
      "organizations:DescribeAccount",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_compute_optimiser" {
  count         = var.compute_opt_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_compute_optimiser.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.compute_optimiser_cloudwatch_rule[0].arn

  depends_on = [module.lambda_compute_optimiser]
}

resource "aws_cloudwatch_event_rule" "compute_optimiser_cloudwatch_rule" {
  count               = var.compute_opt_count
  name                = "compute_optimiser_lambda_trigger"
  schedule_expression = var.first_of_the_month_cron
}

resource "aws_cloudwatch_event_target" "compute_optimiser_lambda" {
  count     = var.compute_opt_count
  rule      = aws_cloudwatch_event_rule.compute_optimiser_cloudwatch_rule[0].name
  target_id = "compute_optimiser_lambda"
  arn       = module.lambda_compute_optimiser.function_arn
}

resource "aws_cloudwatch_metric_alarm" "compute_optimiser_lambda_function_error_alarm" {
  alarm_name                = "${module.lambda_compute_optimiser.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.lambda_compute_optimiser.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_compute_optimiser.function_name
  }
  # alarm_actions = ["${module.admin-sns-email-topic.arn}"]
}

