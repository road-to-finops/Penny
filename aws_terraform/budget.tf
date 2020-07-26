resource "aws_budgets_budget" "cloud_budget_charges" {
  name              = "cloud_budget_charges_${var.env}"
  budget_type       = "COST"
  limit_amount      = "110000"
  limit_unit        = "USD"
  time_period_start = "2020-01-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    LinkedAccount = data.aws_caller_identity.current.account_id
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = "85.0"
    threshold_type      = "PERCENTAGE"
    notification_type   = "FORECASTED"

    subscriber_email_addresses = [var.sender_email]
  }
}

resource "aws_budgets_budget" "cloud_ri_utilisation" {
  name              = "cloud_ri_utilisation_${var.env}"
  budget_type       = "RI_UTILIZATION"
  limit_amount      = "100.0" #RI utlisation must be 100
  limit_unit        = "PERCENTAGE"
  time_period_start = "2020-01-01_00:00"
  time_unit         = "MONTHLY"

  #Cost types (tax, subscriptions etc.) must be defined for RI budgets because the settings conflict with the defaults
  cost_types {
    include_credit             = false
    include_discount           = false
    include_other_subscription = false
    include_recurring          = false
    include_refund             = false
    include_subscription       = true
    include_support            = false
    include_tax                = false
    include_upfront            = false
    use_blended                = false
  }

  #RI Utilization plans require a service cost filter to be set
  cost_filters = {
    Service = "Amazon Relational Database Service"
  }
}

resource "aws_budgets_budget" "savings_plan_utilization" {
  name              = "savings_plan_utilisation_${var.env}"
  budget_type       = "SAVINGS_PLANS_UTILIZATION"
  limit_amount      = "100.0"
  limit_unit        = "PERCENTAGE"
  time_period_start = "2020-01-01_00:00"
  time_unit         = "MONTHLY"

  cost_types {
    include_credit             = false
    include_discount           = false
    include_other_subscription = false
    include_recurring          = false
    include_refund             = false
    include_subscription       = true
    include_support            = false
    include_tax                = false
    include_upfront            = false
    use_blended                = false
  }
}

