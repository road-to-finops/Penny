select line_item_product_code, round(sum("line_item_blended_cost"),2) as cost
from "kpmgcostanalysisathenadatabase"."k_p_m_g_billing_athena_with_i_d"
where month = CAST((month(now())-1) AS VARCHAR) and line_item_usage_account_id like '949913358111%'
group by line_item_product_code, resource_tags_user_application