#!/usr/bin/env python3

import json
import boto3
import os

def lambda_handler(event, context):
    client = boto3.client('cur', 'us-east-1')
    
    S3BucketName = os.environ['BUCKET_NAME']
    Region = os.environ['REGION']
    TimeUnit = os.environ['TIMEUNIT']
    print  (S3BucketName)
   
    response = client.describe_report_definitions()
    print (response)
    
    response = client.put_report_definition(
      ReportDefinition={
          'ReportName': 'mybillingreport',
          'TimeUnit': TimeUnit,
          'Format': 'Parquet',
          'Compression': 'Parquet',
          'AdditionalSchemaElements': [
            'RESOURCES',
            ],
          'S3Bucket': '%s' %S3BucketName,
          'S3Prefix': 'State/lambda',
          'S3Region': '%s' %Region,
          'ReportVersioning': 'OVERWRITE_REPORT',
          'AdditionalArtifacts': [
              'ATHENA',
          ]
      }
  ) 
  
