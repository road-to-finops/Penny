module "lambda_fof" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "fof${var.env}"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 900

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/fof"
  memory_size = "2000"

  // Attach a policy.

  policy        = {json = data.aws_iam_policy_document.fof_policy.json}


  // Add environment variables.
  environment = {
    variables = {
      BUCKET = aws_s3_bucket.s3_bucket.id
      REGION = var.region
    }
  }
}

data "aws_iam_policy_document" "fof_policy" {
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
      "orgonisation:*",
      "organizations:ListAccounts",
      "ec2:*",
      "cloudtrail:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_fof" {
  count         = var.fof_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_fof.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fof_cloudwatch_rule[0].arn

  depends_on = [module.lambda_fof]
}

resource "aws_cloudwatch_event_rule" "fof_cloudwatch_rule" {
  count               = var.fof_trigger_count
  name                = "fof_lambda_trigger"
  schedule_expression = var.fof_cron
}

resource "aws_cloudwatch_event_target" "fof_lambda" {
  count     = var.fof_trigger_count
  rule      = aws_cloudwatch_event_rule.fof_cloudwatch_rule[0].name
  target_id = "fof_lambda"
  arn       = module.lambda_fof.function_arn
}

