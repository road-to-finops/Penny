SELECT "line_item_usage_account_id",
         round(sum("line_item_unblended_cost"),
        2) AS cost
FROM "Database_Value"."Tabel_Value"
WHERE if((date_format(current_timestamp , '%M') = 'January'),month = '12', month = CAST((month(now())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), year = CAST((year(now())-1) AS VARCHAR) ,year = CAST(year(now()) AS VARCHAR))
        AND line_item_usage_account_id LIKE '123444%'
GROUP BY  line_item_usage_account_id; 