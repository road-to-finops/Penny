#Athena createion Lambda

data "archive_file" "athena_zip" {
  type        = "zip"
  source_file = "${path.module}/source/athenalambda.py"
  output_path = "${path.module}/output/athenalambda.zip"
}

resource "aws_lambda_function" "athena" {
  filename         = "${path.module}/output/athenalambda.zip"
  function_name    = "athena"
  role             = aws_iam_role.iam_role_for_athena.arn
  handler          = "athenalambda.lambda_handler"
  source_code_hash = data.archive_file.athena_zip.output_base64sha256
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      DATABASE    = var.athena_db_name
    }
  }
}

#partition
data "archive_file" "athena_partition_zip" {
  type        = "zip"
  source_dir  = "${path.module}/source/athenapartition/"
  output_path = "${path.module}/output/athenapartition.zip"
}

resource "aws_lambda_function" "athena_partition" {
  filename         = "${path.module}/output/athenapartition.zip"
  function_name    = "athenapartition"
  role             = aws_iam_role.iam_role_for_athena.arn
  handler          = "athenapartition.lambda_handler"
  source_code_hash = data.archive_file.athena_zip.output_base64sha256
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      DATABASE    = var.athena_db_name
    }
  }
}

#s3 event lambda

data "archive_file" "crawler_cf_zip" {
  type        = "zip"
  source_file = "${path.module}/source/crawler_cf.py"
  output_path = "${path.module}/output/crawler_cf.zip"
}

resource "aws_lambda_function" "crawler_cf" {
  filename         = "${path.module}/output/crawler_cf.zip"
  function_name    = "crawler_cf"
  role             = aws_iam_role.iam_role_for_athena.arn
  handler          = "crawler_cf.lambda_handler"
  source_code_hash = data.archive_file.crawler_cf_zip.output_base64sha256
  runtime          = "python3.7"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      REGION      = var.region
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crawler_cf.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_bucket.arn
}

#quickight data 
data "archive_file" "quicksight_datazip" {
  type        = "zip"
  source_dir  = "${path.module}/source/quicksight_data/"
  output_path = "${path.module}/output/quicksight_data.zip"
}

resource "aws_lambda_function" "quicksight_data" {
  filename         = "${path.module}/output/quicksight_data.zip"
  function_name    = "quicksight_data"
  role             = aws_iam_role.iam_role_for_athena.arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.athena_zip.output_base64sha256
  runtime          = "python3.6"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      ATHENA_DATABASE = var.athena_db_name
      ACCOUNT_ID      = data.aws_caller_identity.current.account_id
      DATA_SOURCE_ID  = "Billing_Data_Source_Athena"
      DATA_SET_ID     = "Penny_Data_Set_AWS"
      ATHENA_TABLE    = "mybillingreport"
      USER_ARN        = var.user_arn
    }
  }
}

# SPTool_ODPricing_Download
data "archive_file" "sp_od_pricing_zip" {
  type        = "zip"
  source_file = "${path.module}/source/sptool_odpricing_download.py"
  output_path = "${path.module}/output/sp_od_pricing.zip"
}

resource "aws_lambda_function" "sp_od_pricing" {
  filename         = "${path.module}/output/sp_od_pricing.zip"
  function_name    = "SPTool_ODPricing_Download"
  role             = aws_iam_role.iam_role_for_athena.arn
  handler          = "sptool_odpricing_download.lambda_handler"
  source_code_hash = data.archive_file.sp_od_pricing_zip.output_base64sha256
  runtime          = "python3.8"
  memory_size      = "2688"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
    }
  }

  tags = {
    "Team" = "FinOps"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_sp_od_pricing" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sp_od_pricing.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sp_od_pricing_cloudwatch_rule.arn
}

resource "aws_cloudwatch_event_rule" "sp_od_pricing_cloudwatch_rule" {
  name                = "sp_od_pricing_lambda_trigger"
  schedule_expression = var.service_dynamo_cron
}

resource "aws_cloudwatch_event_target" "sp_od_pricing_lambda" {
  rule      = aws_cloudwatch_event_rule.sp_od_pricing_cloudwatch_rule.name
  target_id = "sp_od_pricing_lambda_target"
  arn       = aws_lambda_function.sp_od_pricing.arn
}

# SPTool_SPPricing_Download
data "archive_file" "sp_sp_pricing_zip" {
  type        = "zip"
  source_file = "${path.module}/source/sptool_sppricing_download.py"
  output_path = "${path.module}/output/sp_sp_pricing.zip"
}

resource "aws_lambda_function" "sp_sp_pricing" {
  filename         = "${path.module}/output/sp_sp_pricing.zip"
  function_name    = "SPTool_SPPricing_Download"
  role             = aws_iam_role.iam_role_for_athena.arn
  handler          = "sptool_sppricing_download.lambda_handler"
  source_code_hash = data.archive_file.sp_sp_pricing_zip.output_base64sha256
  runtime          = "python3.8"
  memory_size      = "2688"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.s3_bucket.id
      DATABASE    = var.pricing_db_name
    }
  }

  tags = {
    "Team" = "FinOps"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_sp_sp_pricing" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sp_sp_pricing.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sp_sp_pricing_cloudwatch_rule.arn
}

resource "aws_cloudwatch_event_rule" "sp_sp_pricing_cloudwatch_rule" {
  name                = "sp_sp_pricing_lambda_trigger"
  schedule_expression = var.service_dynamo_cron
}

resource "aws_cloudwatch_event_target" "sp_sp_pricing_lambda" {
  rule      = aws_cloudwatch_event_rule.sp_sp_pricing_cloudwatch_rule.name
  target_id = "sp_sp_pricing_lambda_target"
  arn       = aws_lambda_function.sp_sp_pricing.arn
}

