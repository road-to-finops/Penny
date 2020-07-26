#Run at 2:00 am (UTC) every 1st day of the month
resource "aws_cloudwatch_event_rule" "monthly_partition_rule" {
  name                = "monthly_partition_rule"
  schedule_expression = "cron(0 2 1 * ? *)"
}

#cron job in cloudwatch to run lambda
resource "aws_cloudwatch_event_target" "monthly_partition_rule" {
  rule      = aws_cloudwatch_event_rule.monthly_partition_rule.name
  target_id = "lambda_partition_target"
  arn       = aws_lambda_function.athena_partition.arn
}

