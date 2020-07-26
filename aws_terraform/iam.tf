data "aws_iam_policy_document" "billing_policy" {
  statement {
    actions = [
      "aws-portal:*Billing",
      "awsbillingconsole:*Billing",
      "aws-portal:*Usage",
      "awsbillingconsole:*Usage",
      "aws-portal:*PaymentMethods",
      "awsbillingconsole:*PaymentMethods",
      "budgets:ViewBudget",
      "budgets:ModifyBudget",
      "cur:*",
      "s3:*",
      "quicksight:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "billing_policy" {
  name   = "QuickSightPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.billing_policy.json
}

