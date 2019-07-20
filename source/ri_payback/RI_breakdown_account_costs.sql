SELECT "bill_payer_account_id", "bill_billing_period_start_date", "month", "line_item_usage_account_id", "reservation_reservation_a_r_n", "line_item_product_code", "line_item_usage_type",  sum("line_item_usage_amount") as Usage, "line_item_unblended_rate", sum("line_item_unblended_cost") as Cost, "line_item_line_item_description", "pricing_public_on_demand_rate", sum("pricing_public_on_demand_cost") AS PublicCost, sum("reservation_recurring_fee_for_usage") AS RI 

FROM "Database_Value"."Tabel_Value"

WHERE "line_item_line_item_Type" LIKE '%DiscountedUsage%' AND month = CAST((month(now())-1) AS VARCHAR)
GROUP BY "bill_payer_account_id", "bill_billing_period_start_date", "line_item_usage_account_id", "reservation_reservation_a_r_n", "line_item_product_code", "line_item_usage_type", "line_item_unblended_rate", "line_item_line_item_description", "pricing_public_on_demand_rate", "month"