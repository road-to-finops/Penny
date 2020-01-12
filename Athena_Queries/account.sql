select line_item_product_code, round(sum("line_item_blended_cost"),2) as cost
from "table"."database"
where if((date_format(current_timestamp , '%M') = 'January'),month = '12', month = CAST((month(now())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), year = CAST((year(now())-1) AS VARCHAR) ,year = CAST(year(now()) AS VARCHAR)) and line_item_usage_account_id like '123456789%'
group by line_item_product_code, resource_tags_user_application