module "lambda_ri_reccomendation" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "RI_Reccomendation"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/ri"

  // Attach a policy.

  policy        = {json = data.aws_iam_policy_document.ri_reccomendation_policy.json}

  // Add environment variables.
  environment = {
    variables = {
      BUCKET       = aws_s3_bucket.s3_bucket.id
      SENDEREMAIL  = var.sender_email
      RECIVEREMAIL = var.reciver_email
      REGION       = var.region
    }
  }
  tags = {
    Project = "Penny"
    Team    = "FinOps"
  }
}

data "aws_iam_policy_document" "ri_reccomendation_policy" {
  statement {
    actions = [
      "aws-portal:*",
      "s3:*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole",
      "SES:SendRawEmail",
      "SES:SendEmail",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "cur:*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ce:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_ri_reccomendation" {
  count         = var.ri_rec_trigger_count
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_ri_reccomendation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ri_reccomendation_cloudwatch_rule[0].arn

  depends_on = [module.lambda_ri_reccomendation]
}

resource "aws_cloudwatch_event_rule" "ri_reccomendation_cloudwatch_rule" {
  count               = var.ri_rec_trigger_count
  name                = "ri_reccomendation_lambda_trigger"
  schedule_expression = var.ri_reccomendation_cron
}

resource "aws_cloudwatch_event_target" "ri_reccomendation_lambda" {
  count     = var.ri_rec_trigger_count
  rule      = aws_cloudwatch_event_rule.ri_reccomendation_cloudwatch_rule[0].name
  target_id = "ri_reccomendation_lambda"
  arn       = module.lambda_ri_reccomendation.function_arn
}

