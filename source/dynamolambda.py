#!/usr/bin/env python3

import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('dynamodb')
    print "get dynamo"
    
    response = client.scan(
        TableName='inv.AWSAccounts')


    txt = open("/tmp/dynamo.csv", "w")
    
    txt.write("account_id,account_name,project_name\n")
    
    for element in response['Items']:
    
        account_id = element["account_id"]["S"]
        account_name = element["account_name"]["S"]
        if 'project_name' in element:
            project_name = element["project_name"]["S"]
        else:
            project_name = ""
        txt.write("%s,%s,%s\n" % (account_id, account_name, project_name))
    
    txt.close()	
    
    #S3

    s3 = boto3.resource('s3')
    s3.meta.client.upload_file('/tmp/dynamo.csv', 'kpmgcloud-cost-report', 'dynamo.csv')
    
