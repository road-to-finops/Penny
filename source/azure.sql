 CREATE external TABLE kpmgcostanalysisathenadatabase.azure (
  accountownerid string,
  account string,
  serviceadministratorid string,
  subscriptionid string,
  subscriptionguid string,
  subscription string,
  date date,
  month string,
  day string,
  year string,
  product string,
  meterid string,
  metercategor string,
  metersubcategory string,
  meterregion string,
  metername string,
  consumed string,
  resourcerate int,
  extendedcost int,
  resourcelocation string,
  consumedservice string,
  instanceid string,
  serviceinfo1 string,
  serviceinfo2 string,
  additionalinfo string,
  tags string,
  storeserviceidentifier string,
  departmentname string,
  costcenter string,
  unitofmeasure string,
  resource string,
  chargesbilledseparately string 
)PARTITIONED BY (
  year string,
  month string 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ','
) LOCATION 's3://kpmgcloud-cost-report/Azure/'
TBLPROPERTIES ('has_encrypted_data'='false');
 