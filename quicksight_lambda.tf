
#quickight data 
data "archive_file" "quicksight_datazip" {
  type        = "zip"
  source_dir  = "${path.module}/source/quicksight_data/"
  output_path = "${path.module}/output/quicksight_data.zip"
}

resource "aws_lambda_function" "quicksight_data" {
  filename         = "${path.module}/output/quicksight_data.zip"
  function_name    = "quicksight_data"
  role             = "${aws_iam_role.iam_role_for_athena.arn}"
  handler          = "main.lambda_handler"
  source_code_hash = "${data.archive_file.athena_zip.output_base64sha256}"
  runtime          = "python3.6"
  memory_size      = "512"
  timeout          = "150"

  environment {
    variables = {
      ATHENA_DATABASE = "${var.athena_db_name}"
      ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
      DATA_SOURCE_ID="Billing_Data_Source_Athena"
      DATA_SET_ID="Penny_Data_Set_AWS"
      ATHENA_TABLE="mybillingreport"
      USER_ARN="${var.user_arn}"
    }
  }
}