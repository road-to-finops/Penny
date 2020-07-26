----------- join with cost 
SELECT accountid, resource_id, method, "round"("sum"("line_item_unblended_cost")) as potential_saving
FROM Database_Value.fof 
left JOIN "Database_Value"."Tabel_Value" ON
  "database_value"."line_item_resource_id" = "fof"."resource_id" 
where if((date_format(current_timestamp , '%M') = 'January'),fof.month = '12', fof.month = CAST((month(now())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), fof.year = CAST((year(now())-1) AS VARCHAR) ,fof.year = CAST(year(now()) AS VARCHAR))
group by resource_id, fof.accountid, fof.method
limit 10


-- case example for EIP

SELECT accountid, resource_id, method, 
sum(CASE
    WHEN method = 'Elastic IP' THEN 3.36
    else line_item_unblended_cost
    
END) as potential_savings
FROM Database_Value.fof 
left JOIN "Database_Value"."Tabel_Value" ON
  "database_value"."line_item_resource_id" = "fof"."resource_id" 
where if((date_format(current_timestamp , '%M') = 'January'),fof.month = '12', fof.month = CAST((month(now())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), fof.year = CAST((year(now())-1) AS VARCHAR) ,fof.year = CAST(year(now()) AS VARCHAR))
group by resource_id, fof.accountid, fof.method
limit 10