module "lambda_cur" {
  source = "github.com/claranet/terraform-aws-lambda.git?ref=v1.2.0"

  function_name = "lambda_cur"
  description   = "Deployment deploy status task"
  handler       = "cur.lambda_handler"
  runtime       = "python3.6"
  timeout       = 60

  // Specify a file or directory for the source code.
  source_path = "${path.module}/source/cur"

  policy        = {json = data.aws_iam_policy_document.cur_policy.json}


  // Add environment variables.
  environment = {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      REGION      = var.region
      TIMEUNIT = var.timeunit
    }
  }
  tags = {
    Project = "Penny"
    Team    = "FinOps"
  }
}

data "aws_iam_policy_document" "cur_policy" {
  statement {
    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingActivities",
      "application-autoscaling:DescribeScalingPolicies",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "datapipeline:DescribeObjects",
      "datapipeline:DescribePipelines",
      "datapipeline:GetPipelineDefinition",
      "datapipeline:ListPipelines",
      "datapipeline:QueryObjects",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:ListTables",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DescribeLimits",
      "dynamodb:ListGlobalTables",
      "dynamodb:DescribeGlobalTable",
      "dynamodb:DescribeBackup",
      "dynamodb:ListBackups",
      "dynamodb:DescribeContinuousBackups",
      "dax:Describe*",
      "dax:List*",
      "dax:GetItem",
      "dax:BatchGetItem",
      "dax:Query",
      "dax:Scan",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "iam:GetRole",
      "iam:ListRoles",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTopics",
      "lambda:ListFunctions",
      "lambda:ListEventSourceMappings",
      "lambda:GetFunctionConfiguration",
      "s3:*",
      "s3:GetBucketLocation",
      "lambda:InvokeFunction",
      "cur:DescribeReportDefinitions",
      "cur:PutReportDefinition",
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
      "cur:DescribeReportDefinitions",
      "cur:PutReportDefinition",
    ]

    resources = [
      "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:*/",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_cur" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_cur.function_name
  principal     = "events.amazonaws.com"
  depends_on    = [module.lambda_cur]
}

