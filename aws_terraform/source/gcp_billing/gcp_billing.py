#!/usr/bin/python
# -*- coding: utf-8 -*-
# cloudstoragedownload.py
# It is an example that handles Cloud Storage buckets on Google Cloud Platform (GCP).
# Download an object from a Cloud Storage bucket to a local file.
# You must provide 3 parameters:
# BUCKET_NAME     = Bucket name
# OBJECT_NAME     = Object name in the bucket
# LOCAL_FILE_NAME = Local file name
# https://github.com/alfonsof/google-cloud-python-examples/blob/master/gcloudstoragedownload/cloudstoragedownload.py
# https://google-auth.readthedocs.io/en/latest/reference/google.oauth2.service_account.html
import logging
import sys
import os
import boto3
import json
import csv
from google.oauth2 import service_account
from google.cloud.exceptions import NotFound
from google.cloud.exceptions import Forbidden
from google.cloud import bigquery
from google.auth.transport.requests import TimeoutGuard
import datetime
from datetime import date, timedelta
 # initiate logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def key():

    key = json.loads(os.environ['API'])

    with open(r"/tmp/key.text", "w") as out_file:
        json.dump(key, out_file)

    return


def main(year, month, project, query):

    # Make a list of command line arguments, omitting the [0] element
    # which is the script itself. 
    key()

    print("got key")
    #credentials = service_account.Credentials.from_service_account_info(info)
    credentials = service_account.Credentials.from_service_account_file(
        '/tmp/key.text')
    # Instantiate the client.
    client = bigquery.Client(project=project, credentials=credentials)

    print('Downloading an object from a Big Query to a local file ...')
    try:

        # Perform a query.
        data = f"{year}{month}"
        query = query.replace('yearmonth', data)
        query_job = client.query(query)  # API request
        rows = query_job.result()  # Waits for query to finish

        records = [dict(rows) for rows in query_job]
    except NotFound:
        print('Error: Check Query!!')
        pass
    except Forbidden:
        print('Error: Forbidden, you do not have access to it!!')
        pass

    return records

def make_json(month, records):
    
    logger.info("Creating json file")    
    
    try:
        with open(f"/tmp/kpmg-{month}.json", "w") as outfile:
            for result in records:
                json.dump(result, outfile)
                outfile.write('\n')
        logger.info('json created')

    except:
        logging.exception("!!!json creation failed!!!")
        raise

# This is the standard boilerplate that calls the main() function.
def lambda_handler(event, context):
   
    S3BucketName = os.environ["S3_BUCKET_NAME"]
    project = os.environ["BILLING_PROJECT"] #project='billing-data-193675'
    query = os.environ["QUERY"] 

    prev = date.today().replace(day=1) - timedelta(days=1)
    month = prev.month
    year = prev.year

    if month < 10:
        bqmonth = f"0{month}"
    else:
        bqmonth = month

    record =  main(year, bqmonth, project, query)

    make_json(bqmonth, record)
    
    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(
        f"/tmp/kpmg-{bqmonth}.json", S3BucketName, f"GCP/year={year}/month={month}/kpmg-{year}-{month}.json" 
    )