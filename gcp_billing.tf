module "lambda_gcp_billing" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v0.11.3"

  function_name = "gcp_billing"
  description   = "Deployment deploy status task"
  handler       = "gcp_billing.lambda_handler"
  runtime       = "python3.6"
  timeout       = 600

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/gcp_billing"
  memory_size = "600"

  // Attach a policy.

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.gcp_billing_policy.json}"
  // Add a dead letter queue.
  attach_dead_letter_config = false
  // Deploy into a VPC.
  attach_vpc_config = false
  // Add environment variables.
  environment {
    variables {
      API             = "${data.template_file.GoogleCloud.rendered}"
      S3_BUCKET_NAME  = "${aws_s3_bucket.s3_bucket.id}"
      GCP_BUCKET      = "${var.gcp_bucket}"
      GCP_BILLING_KEY = "${var.gcp_billing_key}"
    }
  }
}

data "template_file" "GoogleCloud" {
  template = "${file("source/gcp_billing/googleapi.json")}"
}

data "aws_iam_policy_document" "gcp_billing_policy" {
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
}

resource "aws_lambda_permission" "allow_cloudwatch_gcp_billing" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_gcp_billing.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.gcp_billing_cloudwatch_rule.arn}"

  depends_on = ["module.lambda_gcp_billing"]
}

resource "aws_cloudwatch_event_rule" "gcp_billing_cloudwatch_rule" {
  name                = "gcp_billing_lambda_trigger"
  schedule_expression = "${var.gcp_billing_cron}"
}

resource "aws_cloudwatch_event_target" "gcp_billing_lambda" {
  rule      = "${aws_cloudwatch_event_rule.gcp_billing_cloudwatch_rule.name}"
  target_id = "gcp_billing_lambda"
  arn       = "${module.lambda_gcp_billing.function_arn}"
}
