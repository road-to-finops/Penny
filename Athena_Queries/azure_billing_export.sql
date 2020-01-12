SELECT project,
         subscriptionguid,
         subscriptionname,
         "cost code" ,
        "cost centre",
         sum(cost) AS cost
FROM database.azure
LEFT JOIN "table"."database"
    ON azure.subscriptionguid = accounts.account_number
WHERE if((date_format(current_timestamp , '%M') = 'January'),month = '12', month = CAST((month(now())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), year = CAST((year(now())-1) AS VARCHAR) ,year = CAST(year(now()) AS VARCHAR))
GROUP BY  project, account_number, subscriptionguid, subscriptionname, "cost code", "cost centre"