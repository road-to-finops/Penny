#!/usr/bin/env python3
import logging
import boto3
from botocore.exceptions import ClientError
import os
import datetime
import json
import trusted_advisor
from datetime import date, timedelta
log = logging.getLogger()

def assume_role(account_id, service, region):
    role_arn = "arn:aws:iam::%s:role/OrganizationAccountAccessRole" % account_id
    sts_client = boto3.client('sts')
    if region is None:
        region = sts_client.meta.region_name
    
    try:

        assumedRoleObject = sts_client.assume_role(
            RoleArn=role_arn,
            RoleSessionName="AssumeRoleRoot"
            )
            
        credentials = assumedRoleObject['Credentials']
        client = boto3.client(
            service,
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken'],
            region_name = region
        )
        return client

    except ClientError as e:
        logging.warning("Unexpected error Account %s: %s" % (account_id, e))
        return None

def lambda_handler(event, context):
    result = []
    team = ""
    bucket_name = os.environ["BUCKET_NAME"]

    try:
        for record in event['Records']:
           
            account_id = record["body"]
            
            print(account_id)

    
    
            try:
                client = assume_role(account_id, 'support', 'us-east-1')
                result.append(trusted_advisor.get_checks(team, account_id, client))
                
            except Exception as e:
                pass
                logging.warning("%s" % e)
            test= []
            #combine data
            for item in result:
                for item2 in item:
                    test.append(item2)
            
            #attach_file = generate_csv(test, headings=['name','id','resourceId','team','account_id', 'Region', 'status', 'Estimated Monthly Savings', 'Monthly Storage Cost', 'Estimated Monthly Savings (On Demand)','Volume Type', 'Volume Name' , 'Volume ID','Volume Size', 'Snapshot ID', 'Snapshot Name', 'Snapshot Age', 'IP Address','Load Balancer Name', 'Number of Days Low Utilization', 'isSuppressed', 'Hourly Instance Usage Max/Average/Min', 'Upfront Cost', 'Reason', 'Days Since Last Connection', 'Multi-AZ', 'Operating System', 'DB Instance Name', 'Recommended Additional 3-Year RIs', 'Instance ID', 'Instance Type', 'Instance Name', 'Storage Provisioned (GB)', 'Recommended Additional 1-Year RIs', '14-Day Average CPU Utilization', '14-Day Average Network I/O', 'Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7', 'Day 8', 'Day 9', 'Day 10', 'Day 11', 'Day 12', 'Day 13', 'Day 14', 'month', 'year','date'])


            with open('/tmp/ta.json', 'w') as outfile:
                for account in test:
                    #fix duplicate region issue
                    if account['name']!= "Low Utilization Amazon EC2 Instances":
                        try:
                            account['Region/AZ'] = account['Region']
                            del account['Region']
                        except Exception as e:
                            pass
                            logging.warning("%s-%s" % (e, account['id']))
                    #removing dolla sighn
                    if 'Monthly Storage Cost' in account.keys():
                        cost = account['Monthly Storage Cost']
                        account['Monthly Storage Cost'] = cost[1:]
                    if 'Estimated Monthly Savings' in account.keys():
                        ecost = account['Estimated Monthly Savings']
                        account['Estimated Monthly Savings'] = ecost[1:]

                    if 'Estimated Monthly Savings (On Demand)' in account.keys():
                        odcost = account['Estimated Monthly Savings (On Demand)']
                        new_string = odcost.replace(",","")
                        account['Estimated Monthly Savings (On Demand)'] = new_string[1:]
                    

                    #adding a cost for EIP
                    if account['name']== "Unassociated Elastic IP Addresses":
                        account['Estimated Monthly Savings'] = '3.36'
                        
                    json.dump(account, outfile)
                    outfile.write('\n')

            today = date.today()
            year = today.year
            month = today.month

            
            s3 = boto3.resource("s3")
            s3.meta.client.upload_file(
                "/tmp/ta.json", bucket_name, "Trusted_Advisor/year=%s/month=%s/ta_%s_%s_%s.json" %(year, month, account_id, month, year)
            )
    except Exception as e:
        # Send some context about this error to Lambda Logs
        logging.warning("%s" % e)
        