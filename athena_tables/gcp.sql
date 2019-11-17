CREATE EXTERNAL TABLE IF NOT EXISTS database.gcp_billing (
  `accountid` string,
  `lineitem` string,
  `starttime` string,
  `endtime` string,
  `project` string,
  `measurement1` string,
  `measurement1totalconsumption` int,
  `measurement1units` string,
  `credit1` string,
  `credit1amount` int,
  `credit1currency` string,
  `cost` int,
  `currency` string,
  `projectnumber` string,
  `projectid` string,
  `projectname` string,
  `projectlabels` string,
  `description` string 
) PARTITIONED BY (
  year string,
  month string 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ';',
  'field.delim' = ';'
) LOCATION 's3:/bucket/GCP/'
TBLPROPERTIES ('has_encrypted_data'='false', 'skip.header.line.count'='1');