# Trusted Advisor Que
resource "aws_sqs_queue" "ta_account_que" {
  name                       = "ta_account_que${var.env}"
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 300

  tags = {
    Team = "FinOps"
  }
}

resource "aws_sqs_queue_policy" "sqs_ta_queue_policy" {
  queue_url = aws_sqs_queue.ta_account_que.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.ta_account_que.arn}"
    }
  ]
}
POLICY

}

# Compute optimiser Que

resource "aws_sqs_queue" "co_account_que" {
  name                       = "co_account_que${var.env}"
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 300

  tags = {
    Team = "FinOps"
  }
}

resource "aws_sqs_queue_policy" "sqs_co_queue_policy" {
  queue_url = aws_sqs_queue.co_account_que.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.co_account_que.arn}"
    }
  ]
}
POLICY

}

# Azure Billing Data Collector Que
resource "aws_sqs_queue" "azure_collector_que" {
  name                       = "azure_collector_que${var.env}"
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 1800

  tags = {
    Team = "FinOps"
  }
}

resource "aws_sqs_queue_policy" "azure_collector_queue_policy" {
  queue_url = aws_sqs_queue.azure_collector_que.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.azure_collector_que.arn}"
    }
  ]
}
POLICY

}

# Event source from SQS 

resource "aws_lambda_event_source_mapping" "ta_event_source_mapping" {
  event_source_arn = aws_sqs_queue.ta_account_que.arn
  enabled          = true
  function_name    = module.lambda_trusted_advisor.function_arn
}

#resource "aws_lambda_event_source_mapping" "co_event_source_mapping" {
#  event_source_arn = "${aws_sqs_queue.co_account_que.arn}"
#  enabled          = true
#  function_name    = "${module.lambda_compute_optimiser.function_arn}"
#}

resource "aws_lambda_event_source_mapping" "azure_collector_event_source_mapping" {
  event_source_arn = aws_sqs_queue.azure_collector_que.arn
  enabled          = true
  function_name    = module.azure_billing_collector_lambda.function_arn
}

