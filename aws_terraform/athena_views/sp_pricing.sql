CREATE VIEW SP_Usage AS
SELECT cur.line_item_usage_account_id,
         cur.line_item_usage_start_date,
         to_unixtime(cur.line_item_usage_start_date) AS EpochTime,
         cur.product_instance_type,
         cur.product_location,
         cur.product_operating_system,
         cur.product_tenancy,
         SUM(cur.line_item_unblended_cost) AS ODPrice,
         SUM(cur.line_item_unblended_cost*(cast(pr.SPRate AS double)/cast(pr.ODRate AS double))) SPPrice,
         abs(SUM(cast(pr.SPRate AS double)) - SUM (cast(pr.ODRate AS double))) / SUM(cast(pr.ODRate AS double))*100 AS DiscountRate,
         SUM(cur.line_item_usage_amount) AS InstanceCount
FROM ${Database_Value}.${Database_Table} cur
JOIN pricing.pricing pr
    ON (cur.product_location = pr.Region)
        AND (cur.line_item_operation = pr.OS)
        AND (cur.product_instance_type = pr.InstanceType)
        AND (cur.product_tenancy = pr.Tenancy)
WHERE cur.line_item_product_code LIKE '%EC2%'
        AND cur.product_instance_type NOT LIKE ''
        AND cur.product_operating_system NOT LIKE 'NA'
        AND cur.line_item_unblended_cost > 0
GROUP BY  cur.line_item_usage_account_id, cur.line_item_usage_start_date, cur.product_instance_type, cur.product_location, cur.product_operating_system, cur.product_tenancy
ORDER BY  cur.line_item_usage_start_date ASC, DiscountRate DESC
