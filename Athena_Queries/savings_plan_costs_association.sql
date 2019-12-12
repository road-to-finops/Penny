SELECT round(sum(savings_plan_savings_plan_effective_cost),4) AS Quantity, line_item_usage_account_id 
FROM "database"."table" 
where month = CAST((month(now())-1) AS VARCHAR)
group by line_item_usage_account_id
order by Quantity DESC