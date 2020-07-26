SELECT sum("cost") as costs, "account name", subscriptionguid, metercategory
FROM "kpmgcostanalysisathenadatabase"."azure"
RIGHT JOIN kpmgcostanalysisathenadatabase.accounts
ON azure.subscriptionguid = accounts."account id"
where project  = '<project>'
and year = '2020' and month = '3'
group by "account name", subscriptionguid ,metercategory
ORDER BY subscriptionguid ASC