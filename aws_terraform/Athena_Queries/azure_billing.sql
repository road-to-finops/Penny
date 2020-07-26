SELECT sum("cost") as costs, subscriptionguid, metercategory
FROM "Database_Value"."azure"
where year = '2020' and month = '3'
group by  subscriptionguid ,metercategory
ORDER BY subscriptionguid ASC