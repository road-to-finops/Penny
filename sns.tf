resource "aws_sns_topic" "aws_penny" {
  name = "aws_penny"
}

resource "aws_sns_topic_policy" "default" {
  arn = "${aws_sns_topic.aws_penny.arn}"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "${aws_sns_topic.aws_penny.arn}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "*"
        }
      }
    },
    {
      "Sid": "_s3",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SNS:Publish",
      "Resource": "${aws_sns_topic.aws_penny.arn}",
      "Condition": {
        "StringEquals": {
          "aws:SourceArn": "${aws_s3_bucket.s3_bucket.arn}"
        }
      }
    }
  ]
}
POLICY
}
