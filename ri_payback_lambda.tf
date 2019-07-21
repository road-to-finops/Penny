module "lambda_ri_payback" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v0.11.3"

  function_name = "RI_payback"
  description   = "Deployment deploy status task"
  handler       = "athena.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/ri_payback"

  // Attach a policy.

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.athena_policy.json}"
  // Add a dead letter queue.
  attach_dead_letter_config = false
  // Deploy into a VPC.
  attach_vpc_config = false
  // Add environment variables.
  environment {
    variables {
      BUCKET_LOCATION = "s3://${aws_s3_bucket.s3_bucket.id}/Quick/RI"
      DATABASE        = "${var.athena_db_name}"
      TABLE           = "mybillingreport"
      REGION          = "${var.region}"
    }
  }
}

data "aws_iam_policy_document" "athena_policy" {
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
    ]
  }

  statement {
    actions = [
      "athena:*",
    ]

    resources = [
      "arn:aws:athena:*:*:workgroup/primary",
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
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:CreateBucket",
      "s3:AbortMultipartUpload",
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*",
      "${aws_s3_bucket.s3_bucket.arn}",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_ri_payback" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_ri_payback.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ri_payback_cloudwatch_rule.arn}"

  depends_on = ["module.lambda_ri_payback"]
}

resource "aws_cloudwatch_event_rule" "ri_payback_cloudwatch_rule" {
  name                = "ri_payback_lambda_trigger"
  schedule_expression = "${var.ri_payback_cron}"
}

resource "aws_cloudwatch_event_target" "ri_payback_lambda" {
  rule      = "${aws_cloudwatch_event_rule.ri_payback_cloudwatch_rule.name}"
  target_id = "lambda_target"
  arn       = "${module.lambda_ri_payback.function_arn}"
}
