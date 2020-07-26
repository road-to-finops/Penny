CREATE VIEW pricing.pricing AS
SELECT sp.location AS Region,
         sp.discountedoperation AS OS,
         REPLACE(od.col18,
         '"') AS InstanceType, REPLACE(od.col35, '"') AS Tenancy, REPLACE(od.col9, '"') AS ODRate, sp.discountedrate AS SPRate
FROM pricing.sp_pricedata sp
JOIN pricing.od_pricedata od
    ON ((sp.discountedusagetype = REPLACE(od.col46, '"'))
        AND (sp.discountedoperation = REPLACE(od.col47, '"')))
WHERE od.col9 IS NOT NULL
        AND sp.location NOT LIKE 'Any'
        AND sp.purchaseoption LIKE 'No Upfront'
        AND sp.leasecontractlength = 1