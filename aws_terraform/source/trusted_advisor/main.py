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
        logging.warning("Unexpected error Account {account_id}: {e}")
        return None

def lower_keys(accounts_data):
    if isinstance(accounts_data, list):
        return [lower_keys(value) for value in accounts_data]
    elif isinstance(accounts_data, dict):
        return dict((key.lower(), lower_keys(value)) for key, value in accounts_data.items())
    else:
        return accounts_data

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
                logging.warning(f"{e}")
                pass
                
            test= []
            #combine data
            for item in result:
                for item2 in item:
                    test.append(item2)
            
            with open('/tmp/ta.json', 'w') as outfile:
                for account in test:
                    #fix duplicate region issue
                    if account['name']!= "Low Utilization Amazon EC2 Instances":
                        try:
                            account['Region/AZ'] = account['Region']
                            del account['Region']
                        except Exception as e:
                            pass
                            logging.warning(f"{e}-{account['id']}")
                    #removing dolla sighn
                    if 'Monthly Storage Cost' in account.keys():
                        
                        cost = account['Monthly Storage Cost']
                        cost2 = cost.replace(",","").replace("$", "")
                        account['Monthly Storage Cost'] = cost2[1:]
                    if 'Estimated Monthly Savings' in account.keys():
                        
                        ecost = account['Estimated Monthly Savings']
                        ecost2 = ecost.replace(",","").replace("$", "")
                        account['Estimated Monthly Savings'] = ecost2[1:]
                    if 'Estimated Monthly Savings (On Demand)' in account.keys():
                        
                        odcost = account['Estimated Monthly Savings (On Demand)']
                        new_string = odcost.replace(",","").replace("$", "")
                        account['Estimated Monthly Savings (On Demand)'] = new_string[1:]
                    

                    #adding a cost for EIP
                    if account['name']== "Unassociated Elastic IP Addresses":
                        account['Estimated Monthly Savings'] = '3.36'

                    account_lower = lower_keys(account)
                    
                    json.dump(account_lower, outfile)

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
       logging.warning(f"{e}" )
    