CREATE EXTERNAL TABLE `azure_marketplace`(
  `id` string COMMENT 'from deserializer', 
  `subscriptionguid` string COMMENT 'from deserializer', 
  `subscriptionname` string COMMENT 'from deserializer', 
  `meterid` string COMMENT 'from deserializer', 
  `usagestartdate` string COMMENT 'from deserializer', 
  `usageenddate` string COMMENT 'from deserializer', 
  `offername` string COMMENT 'from deserializer', 
  `resourcegroup` string COMMENT 'from deserializer', 
  `instanceid` string COMMENT 'from deserializer', 
  `ordernumber` string COMMENT 'from deserializer', 
  `unitofmeasure` string COMMENT 'from deserializer', 
  `costcenter` string COMMENT 'from deserializer', 
  `accountid` int COMMENT 'from deserializer', 
  `accountname` string COMMENT 'from deserializer', 
  `accountownerid` string COMMENT 'from deserializer', 
  `departmentid` int COMMENT 'from deserializer', 
  `departmentname` string COMMENT 'from deserializer', 
  `publishername` string COMMENT 'from deserializer', 
  `planname` string COMMENT 'from deserializer', 
  `consumedquantity` decimal(38,18) COMMENT 'from deserializer', 
  `resourcerate` decimal(38,18) COMMENT 'from deserializer', 
  `extendedcost` decimal(38,18) COMMENT 'from deserializer', 
  `isrecurringcharge` string COMMENT 'from deserializer')
PARTITIONED BY ( 
  `year` string, 
  `month` string)
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat'
LOCATION
  's3://buisnesspennybucket-${account_id}/Azure_Billing/Azure_Marketplace'
TBLPROPERTIES (
  'has_encrypted_data'='false', 
  'transient_lastDdlTime'='1586262811')

  s3://buisnesspennybucket-${account_id}