import boto3
import botocore
import os

def lambda_handler(event, context):
    S3BucketName      = os.environ['BUCKET_NAME']
    athena_database   = os.environ['DATABASE']
    
    client            = boto3.client('athena')

    fd = open('partition.sql', 'r')
    partion = fd.read()
    print partion  
    start_query = client.start_query_execution(
        QueryString='%s' %partion,
        QueryExecutionContext={
            'Database': '%s' %athena_database
        },
        ResultConfiguration={
        'OutputLocation': 's3://%s/Quick/Accounts/results' %S3BucketName,
        }
    )
