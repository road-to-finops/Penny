SELECT team, account_name, line_item_usage_account_id, sum(line_item_unblended_cost)
FROM "kpmgcostanalysisathenadatabase"."k_p_m_g_billing_athena_with_i_d"
RIGHT JOIN kpmgcostanalysisathenadatabase.accounts
 ON k_p_m_g_billing_athena_with_i_d.line_item_usage_account_id = accounts.account_number

where team like 'IADP%' and line_item_product_code like '%AWSCloudTrail' and month = CAST((month(now())-1) AS VARCHAR)
group by line_item_usage_account_id, account_name, team