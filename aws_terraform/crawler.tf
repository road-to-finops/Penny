resource "aws_glue_crawler" "ec2_compute_optimizer" {
  database_name = var.athena_db_name
  name          = "ec2_compute_optimizer_${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Compute_Optimizer/Compute_Optimizer_EC2"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "auto_compute_optimizer" {
  database_name = var.athena_db_name
  name          = "auto_compute_optimizer_${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Compute_Optimizer/Compute_Optimizer_Auto_Scale"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "trusted_advisor" {
  database_name = var.athena_db_name
  name          = "trusted_advisor_${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Trusted_Advisor"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "gcp_billing" {
  database_name = var.athena_db_name
  name          = "gcp_billing_${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/GCP"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "OD_Pricing" {
  database_name = "${var.pricing_db_name}${var.env}"
  name          = "od_pricing${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Pricing/od_pricedata"
  }

  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "SP_Pricing" {
  database_name = "${var.pricing_db_name}${var.env}"
  name          = "sp_pricing${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Pricing/sp_pricedata"
  }

  tags = {
    Team = "FinOps"
  }
}

resource "aws_iam_role_policy" "compute_optimizer_role_policy" {
  name = "compute_optimizer_Role_Policy${var.env}"
  role = aws_iam_role.compute_optimizer_role.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": [
"glue:*",
"s3:GetBucketLocation",
"s3:ListBucket",
"s3:ListAllMyBuckets",
"s3:GetBucketAcl",
"ec2:DescribeVpcEndpoints",
"ec2:DescribeRouteTables",
"ec2:CreateNetworkInterface",
"ec2:DeleteNetworkInterface",
"ec2:DescribeNetworkInterfaces",
"ec2:DescribeSecurityGroups",
"ec2:DescribeSubnets",
"ec2:DescribeVpcAttribute",
"iam:ListRolePolicies",
"iam:GetRole",
"iam:GetRolePolicy",
"cloudwatch:PutMetricData"
],
"Resource": [
"*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:CreateBucket"
],
"Resource": [
"arn:aws:s3:::aws-glue-*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject",
"s3:PutObject",
"s3:DeleteObject"
],
"Resource": [
"arn:aws:s3:::aws-glue-*/*",
"arn:aws:s3:::*/*aws-glue-*/*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject"
],
"Resource": [
"arn:aws:s3:::crawler-public*",
"arn:aws:s3:::aws-glue-*"
]
},
{
"Effect": "Allow",
"Action": [
"logs:CreateLogGroup",
"logs:CreateLogStream",
"logs:PutLogEvents"
],
"Resource": [
"arn:aws:logs:*:*:/aws-glue/*"
]
},
{
"Effect": "Allow",
"Action": [
"ec2:CreateTags",
"ec2:DeleteTags"
],
"Condition": {
"ForAllValues:StringEquals": {
"aws:TagKeys": [
"aws-glue-service-resource"
]
}
},
"Resource": [
"arn:aws:ec2:*:*:network-interface/*",
"arn:aws:ec2:*:*:security-group/*",
"arn:aws:ec2:*:*:instance/*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject",
"s3:PutObject"
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}${var.env}/*"
]
}
]
}
EOF

}

resource "aws_iam_role" "compute_optimizer_role" {
  name = "compute_optimizer_Role${var.env}"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"Service": "glue.amazonaws.com"
},
"Action": "sts:AssumeRole"
}
]
}
EOF


  tags = {
    Team = "FinOps"
  }
}

