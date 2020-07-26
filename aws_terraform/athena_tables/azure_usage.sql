CREATE EXTERNAL TABLE `azure_usage`(
  `servicename` string COMMENT 'from deserializer', 
  `servicetier` string COMMENT 'from deserializer', 
  `location` string COMMENT 'from deserializer', 
  `chargesbilledseparately` boolean COMMENT 'from deserializer', 
  `partnumber` string COMMENT 'from deserializer', 
  `resourceguid` string COMMENT 'from deserializer', 
  `offerid` string COMMENT 'from deserializer', 
  `cost` double COMMENT 'from deserializer', 
  `accountid` int COMMENT 'from deserializer', 
  `productid` int COMMENT 'from deserializer', 
  `resourcelocationid` int COMMENT 'from deserializer', 
  `consumedserviceid` int COMMENT 'from deserializer', 
  `departmentid` int COMMENT 'from deserializer', 
  `accountowneremail` string COMMENT 'from deserializer', 
  `accountname` string COMMENT 'from deserializer', 
  `serviceadministratorid` string COMMENT 'from deserializer', 
  `subscriptionid` int COMMENT 'from deserializer', 
  `subscriptionguid` string COMMENT 'from deserializer', 
  `subscriptionname` string COMMENT 'from deserializer', 
  `date` string COMMENT 'from deserializer', 
  `product` string COMMENT 'from deserializer', 
  `meterid` string COMMENT 'from deserializer', 
  `metercategory` string COMMENT 'from deserializer', 
  `metersubcategory` string COMMENT 'from deserializer', 
  `meterregion` string COMMENT 'from deserializer', 
  `metername` string COMMENT 'from deserializer', 
  `consumedquantity` double COMMENT 'from deserializer', 
  `resourcerate` double COMMENT 'from deserializer', 
  `resourcelocation` string COMMENT 'from deserializer', 
  `consumedservice` string COMMENT 'from deserializer', 
  `instanceid` string COMMENT 'from deserializer', 
  `serviceinfo1` string COMMENT 'from deserializer', 
  `serviceinfo2` string COMMENT 'from deserializer', 
  `storeserviceidentifier` string COMMENT 'from deserializer', 
  `departmentname` string COMMENT 'from deserializer', 
  `costcenter` string COMMENT 'from deserializer', 
  `unitofmeasure` string COMMENT 'from deserializer', 
  `resourcegroup` string COMMENT 'from deserializer', 
  `tags` string COMMENT 'from deserializer')
PARTITIONED BY ( 
  `year` string, 
  `month` string)
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
WITH SERDEPROPERTIES ( 
  'paths'='accountId,accountName,accountOwnerEmail,chargesBilledSeparately,consumedQuantity,consumedService,consumedServiceId,cost,costCenter,date,departmentId,departmentName,instanceId,location,meterCategory,meterId,meterName,meterRegion,meterSubCategory,month,offerId,partNumber,product,productId,resourceGroup,resourceGuid,resourceLocation,resourceLocationId,resourceRate,serviceAdministratorId,serviceInfo1,serviceInfo2,serviceName,serviceTier,storeServiceIdentifier,subscriptionGuid,subscriptionId,subscriptionName,tags,unitOfMeasure,year') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://buisnesspennybucket-${account_id}/Azure_Billing/Azure_Usage'
TBLPROPERTIES (
  'classification'='json', 
  'typeOfData'='file')