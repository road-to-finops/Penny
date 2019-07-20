module "lambda_ri_reccomendation" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v0.11.3"

  function_name = "RI_Reccomendation"
  description   = "Deployment deploy status task"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/ri"

  // Attach a policy.

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.ri_reccomendation_policy.json}"
  // Add a dead letter queue.
  attach_dead_letter_config = false
  // Deploy into a VPC.
  attach_vpc_config = false
  // Add environment variables.
  environment {
    variables {
      SERVICE = "EC2"
    }
  }
}

data "aws_iam_policy_document" "ri_reccomendation_policy" {
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
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_ri_reccomendation.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ri_reccomendation_cloudwatch_rule.arn}"

  depends_on = ["module.lambda_ri_reccomendation"]
}

resource "aws_cloudwatch_event_rule" "ri_reccomendation_cloudwatch_rule" {
  name                = "ri_reccomendation_lambda_trigger"
  schedule_expression = "${var.ri_reccomendation_cron}"
}

resource "aws_cloudwatch_event_target" "ri_reccomendation_lambda" {
  rule      = "${aws_cloudwatch_event_rule.ri_reccomendation_cloudwatch_rule.name}"
  target_id = "ri_reccomendation_lambda"
  arn       = "${module.lambda_ri_reccomendation.function_arn}"
}
