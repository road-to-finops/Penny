CREATE EXTERNAL TABLE IF NOT EXISTS kpmgcostanalysisathenadatabase.fof (
  `team` string,
  `AccountId` string,
  `resource_id` string,
  `s3_bucket` string
  
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ','
) LOCATION 's3://kpmgcloud-cost-report/FinOpsFinder/'
TBLPROPERTIES ('has_encrypted_data'='false', 'skip.header.line.count'='1');