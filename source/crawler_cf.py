#!/usr/bin/env python3

import boto3
import botocore
import os

def lambda_handler(event, context):
    client = boto3.client('cloudformation')

    S3BucketName    = os.environ['BUCKET_NAME']

    response = client.create_stack(
    StackName='Crawler',
    TemplateURL='https://s3-eu-west-1.amazonaws.com/%s/State/lambda/mybillingreport/crawler-cfn.yml' %(S3BucketName),
    Capabilities=[
        'CAPABILITY_IAM'
    ]
    )

