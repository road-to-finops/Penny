CREATE EXTERNAL TABLE IF NOT EXISTS Database_Value.azure ( `accountid` string, `accountname` string, `accountowneremail` string, `consumedquantity` decimal(38,17), `consumedservice` string, `consumedserviceid` int, `cost` decimal(38,17), `costcenter` string, `date` string, `departmentid` string, `departmentname` string, `instanceid` string, `metercategory` string, `meterid` string, `metername` string, `meterregion` string, `metersubcategory` string, `product` string, `productid` string, `resourcegroup` string, `resourcelocation` string, `resourcelocationid` string, `resourcerate`  decimal(38,17), `serviceadministratorid` string, `serviceinfo1` string, `serviceinfo2` string, `storeserviceidentifier` string, `subscriptionguid` string, `subscriptionid` string, `subscriptionname` string, `unitofmeasure` string, `partnumber` string, `resourceguid` string, `offerid` string, `chargesbilledseparately` string, `location` string, `servicename` string, `servicetier` string ) PARTITIONED BY ( year string, month string ) ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe' WITH SERDEPROPERTIES ( 'serialization.format' = '1' ) LOCATION 's3://buisnesspennybucket-account_id/Azure/' TBLPROPERTIES ('has_encrypted_data'='false');