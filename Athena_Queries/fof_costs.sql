SELECT project,
         round(sum("line_item_unblended_cost"),
         2) AS cost
FROM kpmgcostanalysisathenadatabase.k_p_m_g_billing_athena_with_i_d
RIGHT JOIN "default"."test_ffo"
    ON k_p_m_g_billing_athena_with_i_d.line_item_resource_id = test_ffo.resource_id
LEFT JOIN "default"."accounts"ON accounts.account_number = test_ffo.AccountId
WHERE month = CAST((month(now())-1) AS VARCHAR)
GROUP BY  project
ORDER BY  cost DESC;