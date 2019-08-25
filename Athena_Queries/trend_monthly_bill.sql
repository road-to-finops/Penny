select project, account_id,  "account_total",  "cost code" ,"cost centre"
FROM default.trend
left JOIN default.accounts
ON trend.account_id = accounts.account_number
group by  project, account_id ,"account_total", "cost code", "cost centre"
ORDER BY account_total DESC;