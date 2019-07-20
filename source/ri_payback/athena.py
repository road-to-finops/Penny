#!/usr/bin/env python3

import boto3
import time
import csv
import json
import logging
import os
from lambda_base import build_csv_email, send_email, assume_role, format_arn, logger, generate_csv
from io import StringIO
from tenacity import retry, retry_if_exception_type, wait_exponential

Region = os.environ["REGION"]
log = logging.getLogger()
client = boto3.client('athena', Region)
def athena_query():
    
    bucket_location = os.environ["BUCKET_LOCATION"]
    Database = os.environ["DATABASE"]
    Tabel = os.environ["TABLE"]
   

    with open('RI_breakdown_account_costs.sql', 'r') as file:
        QueryString = file.read().replace('\n', '')
        QueryString = QueryString.replace('Database_Value', Database)
        QueryString = QueryString.replace('Tabel_Value', Tabel)

    ExecutionId = client.start_query_execution(
        QueryString=QueryString,
        QueryExecutionContext={
            'Database': Database
        },
        ResultConfiguration={
            'OutputLocation': bucket_location,
            'EncryptionConfiguration': {
                'EncryptionOption': 'SSE_S3'
            }
        }
    )
   
    return ExecutionId.get('QueryExecutionId') 



@retry(retry=retry_if_exception_type(boto3.client('athena').exceptions.InvalidRequestException), wait=wait_exponential(multiplier=1, max=10))
def results(QueryExecutionId):
    results = client.get_query_results(
        QueryExecutionId=QueryExecutionId,
    )

    ResultSet = results.get('ResultSet')
    rows  = ResultSet.get('Rows')
    return rows



def csv_creator(rows):
    f = StringIO()
    writer = csv.writer(f)
    for row in rows:
        writer.writerow([value["VarCharValue"] for value in row["Data"]])
    return f.getvalue()


def lambda_handler(event, context):

    QueryExecutionId = athena_query()
    rows = results(QueryExecutionId)
    attachment  = csv_creator(rows)

