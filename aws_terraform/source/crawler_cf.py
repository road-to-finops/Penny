#!/usr/bin/env python3

import boto3
import botocore
import os

def lambda_handler(event, context):
    client = boto3.client('cloudformation')

    S3BucketName    = os.environ['BUCKET_NAME']
    Region = os.environ['REGION']

    response = client.create_stack(
    StackName='Crawler',
    TemplateURL='https://s3-%s.amazonaws.com/%s/State/lambda/mybillingreport/crawler-cfn.yml' %(Region) %(S3BucketName),
    Capabilities=[
        'CAPABILITY_IAM'
    ]
    )

