SELECT sum(line_item_unblended_cost) AS Quantity,  concat( 'Hosting-AWS','-' ,line_item_usage_account_id,'-' , date_format(current_timestamp - interval '1' month, '%M'),' ' ,"year" ) AS "Item Text"
FROM "Database_Value"."Tabel_Value"
WHERE if((date_format(current_timestamp , '%M') = 'January'),month = '12', month = CAST((month(now())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), year = CAST((year(now())-1) AS VARCHAR) ,year = CAST(year(now()) AS VARCHAR))
        AND line_item_line_item_type != 'Tax'
GROUP BY line_item_usage_account_id, "year" 
order by Quantity desc