module "admin-sns-email-topic" {
  source        = "git::https://terraform-readonly:T87kN3x90yu@stash.customappsteam.co.uk/scm/ter/aws_sns_email_notifications.git/?ref=v0.5"
  display_name  = "CUR Setup is Complete"
  project_name  = "${var.project}"
  email_address = "stephanie.gooch@kpmg.co.uk"
  stack_name    = "cur-sns-email"
}

resource "aws_sns_topic_policy" "default" {
  arn = "${module.admin-sns-email-topic.arn}"

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
      "Resource": "${module.admin-sns-email-topic.arn}",
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
      "Resource": "${module.admin-sns-email-topic.arn}",
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
