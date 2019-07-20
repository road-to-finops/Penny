#!/usr/bin/env python3

import boto3
import botocore
import os

def lambda_handler(event, context):

   # BUCKET_NAME = 'sg-backup-bucket-sandbox'  replace with your bucket name
    KEY = '/Quick/Accounts/accounts_athena.sql' # replace with your object key
    
    athena_database = os.environ['DATABASE']
    S3BucketName    = os.environ['BUCKET_NAME']

    s3 = boto3.resource('s3')
    
    s3.meta.client.download_file('%s' %S3BucketName,
                                'State/lambda/mybillingreport.sql', 
                                '/tmp/mybillingreport.sql')
    
    
    client = boto3.client('athena')
    fd = open('/tmp/accounts_athena.sql', 'r')
    sqlFile = fd.read()


    start_query = client.start_query_execution(
        QueryString='%s' %sqlFile,
        QueryExecutionContext={
            'Database': '%s' %athena_database
        },
        ResultConfiguration={
        'OutputLocation': 's3://%s/athena/results' %S3BucketName,
        }
    )
    
