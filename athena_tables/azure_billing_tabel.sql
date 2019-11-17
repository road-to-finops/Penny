CREATE EXTERNAL TABLE database.azure (
  `accountid` string,
  `accountname` string,
  `accountowneremail` string,
  `consumedquantity` int,
  `consumedservice` string,
  `consumedserviceid` int,
  `cost` decimal(38,17),
  `costcenter` string,
  `date` string,
  `departmentid` string,
  `departmentname` string,
  `instanceid` string,
  `metercategory` string,
  `meterid` string,
  `metername` string,
  `meterregion` string,
  `metersubcategory` string,
  `product` string,
  `productid` string,
  `resourcegroup` string,
  `resourcelocation` string,
  `resourcelocationid` string,
  `resourcerate` int,
  `serviceadministratorid` string,
  `serviceinfo1` string,
  `serviceinfo2` string,
  `storeserviceidentifier` string,
  `subscriptionguid` string,
  `subscriptionid` string,
  `subscriptionname` string,
  `unitofmeasure` string,
  `partnumber` string,
  `resourceguid` string,
  `offerid` string,
  `chargesbilledseparately` string,
  `location` string,
  `servicename` string,
  `servicetier` string 
) PARTITIONED BY (
  year string,
  month string 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ','
) LOCATION 's3://bucket/Azure/'
TBLPROPERTIES ('has_encrypted_data'='false',  'skip.header.line.count'='1');