select "line_item_usage_account_id", round(sum("line_item_unblended_cost"),2) as cost from "table"."database"
where month(bill_billing_period_start_date) = 2 and line_item_usage_account_id like '295755405%'
group by line_item_usage_account_id;
