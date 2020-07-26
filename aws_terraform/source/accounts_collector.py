import boto3
import logging
import os

def sqs_messege(account_id, QueueUrl):
    #posts messege to que
    client = boto3.client('sqs')
    

    response = client.send_message(
        QueueUrl=QueueUrl,
        MessageBody=account_id
    )
    return response


def org_accounts():
    acount_ids = []
    client = boto3.client("organizations", region_name="us-east-1")
    paginator = client.get_paginator("list_accounts")
    response_iterator = paginator.paginate()
    for account in response_iterator:
        for ids in account['Accounts']:
            acount_ids.append(ids)
    logging.info("AWS Org data Gathered")
    return acount_ids
   

def lambda_handler(event, context):
    account_info = org_accounts()

    for account in account_info:
        if  account['Status'] == 'ACTIVE':
            try:
                account_id = account['Id']
                sqs_messege(account_id, os.environ["TA_QUE_URL"])
                logging.info(f"SQS messege sent for {account_id} to TA")
                sqs_messege(account_id, os.environ["CO_QUE_URL"])
                logging.info(f"SQS messege sent for {account_id} to CO" )

            except Exception as e:
                pass
                logging.warning("%s" % e)
        else:
            logging.info(f"account {account['Id']} is not active")
