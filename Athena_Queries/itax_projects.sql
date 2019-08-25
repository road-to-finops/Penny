select "line_item_usage_account_id", account_name, round(sum("line_item_unblended_cost"),2) as cost, month, line_item_product_code
FROM kpmgcostanalysisathenadatabase.k_p_m_g_billing_athena_with_i_d
RIGHT JOIN kpmgcostanalysisathenadatabase.accounts
ON k_p_m_g_billing_athena_with_i_d.line_item_usage_account_id = accounts.account_number
where team like 'ITAX%' 
group by line_item_usage_account_id, account_name, month, line_item_product_code
ORDER BY account_name ASC, month ASC