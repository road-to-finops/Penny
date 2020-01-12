SELECT round(sum(savings_plan_savings_plan_effective_cost),4) AS Quantity, line_item_usage_account_id 
FROM "database"."table" 
where if((date_format(current_timestamp , '%M') = 'January'),month = '12', month = CAST((month(now())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), year = CAST((year(now())-1) AS VARCHAR) ,year = CAST(year(now()) AS VARCHAR))
group by line_item_usage_account_id
order by Quantity DESC