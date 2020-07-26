module "azure_billing_lambda" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "azure_billing"
  description   = "Deployment deploy status task"
  handler       = "azure.lambda_handler"
  runtime       = "python3.6"
  timeout       = 900

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/azure_billing"
  memory_size = "2000"

  // Attach a policy.

  policy        = {json = data.aws_iam_policy_document.azure_billing_policy.json}

  // Add environment variables.
  environment = {
    variables = {
      ENROLMENT       = data.aws_ssm_parameter.azure_enrolmentid.value
      API             = data.aws_ssm_parameter.azure_api.value
      BUCKET_NAME     = aws_s3_bucket.s3_bucket.id
      BUCKET_LOCATION = "s3://${aws_s3_bucket.s3_bucket.id}/athena/azure_lambda"
      DATABASE        = "mybillingreport"
      TABLE           = "azure"
      REGION          = var.region
      QUERY           = data.template_file.azure_billing_sql.rendered
      QUERY_NAME      = "Azure_Monthly_Bill"
    }
  }
}

data "template_file" "azure_billing_sql" {
  template = file("${path.module}/Athena_Queries/azure_billing.sql")

  vars = {
    Database_Value = var.athena_db_name
    Tabel_Value    = "mybillingreport"
  }
}

data "aws_iam_policy_document" "azure_billing_policy" {
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

  statement {
    actions = [
      "athena:*",
      "athena:GetNamespaces",
      "athena:GetExecutionEngine",
      "athena:GetNamespace",
      "athena:GetQueryExecutions",
      "athena:GetExecutionEngines",
      "athena:GetTables",
      "athena:GetTable",
      "athena:ListWorkGroups",
      "athena:RunQuery",
      "athena:GetCatalogs",
      "athena:GetQueryResults",
      "athena:StartQueryExecution",
    ]

    resources = [
      "*",
      "arn:aws:athena:${var.region}:${data.aws_caller_identity.current.account_id}:workgroup/primary",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_azure_billing" {
  count         = var.azure_billing_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.azure_billing_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.azure_billing_cloudwatch_rule[0].arn

  depends_on = [module.azure_billing_lambda]
}

resource "aws_cloudwatch_event_rule" "azure_billing_cloudwatch_rule" {
  count               = var.azure_billing_trigger_count
  name                = "azure_billing_lambda_trigger"
  schedule_expression = var.azure_billing_cron
}

resource "aws_cloudwatch_event_target" "azure_billing_lambda" {
  count     = var.azure_billing_trigger_count
  rule      = aws_cloudwatch_event_rule.azure_billing_cloudwatch_rule[0].name
  target_id = "azure_billing_lambda"
  arn       = module.azure_billing_lambda.function_arn
}

resource "aws_cloudwatch_metric_alarm" "azure_billing_lambda_function_error_alarm" {
  alarm_name                = "${module.azure_billing_lambda.function_name}_lambda_error_alarm"
  comparison_operator       = var.cloudwatch_metric_alarm_comparison_operator
  evaluation_periods        = var.cloudwatch_metric_alarm_evaulation_periods
  metric_name               = var.cloudwatch_metric_alarm_metric_name
  namespace                 = "AWS/Lambda"
  period                    = var.cloudwatch_metric_alarm_period
  statistic                 = var.cloudwatch_metric_alarm_statistic
  threshold                 = var.cloudwatch_metric_alarm_threshold
  alarm_description         = "This metric alarm monitors the errors for the ${module.azure_billing_lambda.function_name} lambda function"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    FunctionName = module.azure_billing_collector_lambda.function_name
  }
  #alarm_actions = ["${aws_sns_topic.penny.arn}"]
}

