#Dynamo Lambda

data "archive_file" "dynamo_zip" {
  type        = "zip"
  source_file = "${path.module}/source/dynamolambda.py"
  output_path = "${path.module}/output/dynamolambda.zip"
}

resource "aws_lambda_function" "dynamo" {
  filename         = "${path.module}/output/dynamolambda.zip"
  function_name    = "dynamo"
  role             = "${aws_iam_role.iam_role_for_dynamo.arn}"
  handler          = "dynamolambda.lambda_handler"
  source_code_hash = "${data.archive_file.dynamo_zip.output_base64sha256}"
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"
}

#Athena createion Lambda

data "archive_file" "athena_zip" {
  type        = "zip"
  source_file = "${path.module}/source/athenalambda.py"
  output_path = "${path.module}/output/athenalambda.zip"
}

resource "aws_lambda_function" "athena" {
  filename         = "${path.module}/output/athenalambda.zip"
  function_name    = "athena"
  role             = "${aws_iam_role.iam_role_for_athena.arn}"
  handler          = "athenalambda.lambda_handler"
  source_code_hash = "${data.archive_file.athena_zip.output_base64sha256}"
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = "${aws_s3_bucket.s3_bucket.id}"
      DATABASE    = "${var.athena_db_name}"
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
  role             = "${aws_iam_role.iam_role_for_athena.arn}"
  handler          = "athenapartition.lambda_handler"
  source_code_hash = "${data.archive_file.athena_zip.output_base64sha256}"
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = "${aws_s3_bucket.s3_bucket.id}"
      DATABASE    = "${var.athena_db_name}"
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
  role             = "${aws_iam_role.iam_role_for_athena.arn}"
  handler          = "crawler_cf.lambda_handler"
  source_code_hash = "${data.archive_file.crawler_cf_zip.output_base64sha256}"
  runtime          = "python3.7"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      BUCKET_NAME = "${aws_s3_bucket.s3_bucket.id}"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.crawler_cf.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3_bucket.arn}"
}
