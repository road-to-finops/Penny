module "lambda_azure_billing" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v0.11.3"

  function_name = "azure_billing"
  description   = "Deployment deploy status task"
  handler       = "azure.lambda_handler"
  runtime       = "python3.6"
  timeout       = 900

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/azure_billing"
  memory_size = "2000"

  // Attach a policy.

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.azure_billing_policy.json}"
  // Add a dead letter queue.
  attach_dead_letter_config = false
  // Deploy into a VPC.
  attach_vpc_config = false
  // Add environment variables.
  environment {
    variables {
      ENROLMENT       = "${var.Enrolmentid}"
      API             = "${var.API}"
      BUCKET_NAME     = "${aws_s3_bucket.s3_bucket.id}"
      BUCKET_LOCATION = "s3://${aws_s3_bucket.s3_bucket.id}/athena/azure_lambda"
      DATABASE        = "mybillingreport"
      TABLE           = "azure"
      REGION          = "${var.region}"
      QUERY           = "${data.template_file.azure_billing_sql.rendered}"
      QUERY_NAME      = "Azure_Monthly_Bill"
    }
  }
}

data "template_file" "azure_billing_sql" {
  template = "${file("${path.module}/Athena_Queries/azure_billing_export.sql")}"

  vars = {
    Database_Value = "${var.athena_db_name}"
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
      "arn:aws:athena:eu-west-1:${var.account_id}:workgroup/primary",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_azure_billing" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_azure_billing.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.azure_billing_cloudwatch_rule.arn}"

  depends_on = ["module.lambda_azure_billing"]
}

resource "aws_cloudwatch_event_rule" "azure_billing_cloudwatch_rule" {
  name                = "azure_billing_lambda_trigger"
  schedule_expression = "${var.azure_billing_cron}"
}

resource "aws_cloudwatch_event_target" "azure_billing_lambda" {
  rule      = "${aws_cloudwatch_event_rule.azure_billing_cloudwatch_rule.name}"
  target_id = "azure_billing_lambda"
  arn       = "${module.lambda_azure_billing.function_arn}"
}
