CREATE EXTERNAL TABLE `azure_reserved`(
  `purchasingenrollment` string COMMENT 'from deserializer', 
  `armskuname` string COMMENT 'from deserializer', 
  `term` string COMMENT 'from deserializer', 
  `region` string COMMENT 'from deserializer', 
  `purchasingsubscriptionguid` string COMMENT 'from deserializer', 
  `purchasingsubscriptionname` string COMMENT 'from deserializer', 
  `accountname` string COMMENT 'from deserializer', 
  `accountowneremail` string COMMENT 'from deserializer', 
  `departmentname` string COMMENT 'from deserializer', 
  `costcenter` string COMMENT 'from deserializer', 
  `currentenrollment` string COMMENT 'from deserializer', 
  `eventdate` string COMMENT 'from deserializer', 
  `billingfrequency` string COMMENT 'from deserializer', 
  `reservationorderid` string COMMENT 'from deserializer', 
  `description` string COMMENT 'from deserializer', 
  `eventtype` string COMMENT 'from deserializer', 
  `quantity` decimal(38,18) COMMENT 'from deserializer', 
  `amount` string COMMENT 'from deserializer', 
  `currency` decimal(38,18) COMMENT 'from deserializer', 
  `reservationordername` string COMMENT 'from deserializer')
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
  's3://buisnesspennybucket-${account_id}/Azure_Billing/Azure_Reserved'
TBLPROPERTIES (
  'has_encrypted_data'='false', 
  'transient_lastDdlTime'='1586263443')