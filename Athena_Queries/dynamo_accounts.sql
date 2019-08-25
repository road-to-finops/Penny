CREATE EXTERNAL TABLE IF NOT EXISTS kpmgcostanalysisathenadatabase.accounts (
  `account_number` string,
  `account_name` string,
  `project` string,
  `Cost Code` string,
  `Cost Centre` string,
  `team` string
  
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ','
) LOCATION 's3://kpmgcloud-cost-report/Quick/accounts/'
TBLPROPERTIES ('has_encrypted_data'='false',   'skip.header.line.count'='1');