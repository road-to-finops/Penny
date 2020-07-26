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
from io import StringIO
from google.oauth2 import service_account
from google.cloud.exceptions import NotFound
from google.cloud.exceptions import Forbidden
from google.cloud import bigquery
from google.auth.transport.requests import TimeoutGuard
import datetime
from datetime import date, timedelta
from lambda_base import (
    build_email,
    send_email,
    format_arn,
    generate_csv,
)

 # initiate logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

Region = os.environ["REGION"]
Sender_email = os.environ["SENDEREMAIL"]
Reciver_email = os.environ["RECIVEREMAIL"]

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
    credentials = service_account.Credentials.from_service_account_file(
        '/tmp/key.text')
    
    # Instantiate the client.
    client = bigquery.Client(project=project, credentials=credentials)
    
    try:

        # Perform a query.
        data = f"{year}{month}"
        query = query.replace('yearmonth', data)
        query_job = client.query(query)  # API request
        rows = query_job.result()  # Waits for query to finish

        records = [dict(rows) for rows in query_job]
    except NotFound:
        print('Error: Bucket/Blob does NOT exists!!')
        pass
    except Forbidden:
        print('Error: Forbidden, you do not have access to it!!')
        pass

    return records

def make_json(month, records):
    
    logger.info("Creating json file")    
    
    try:
        with open(f"/tmp/gcp-{month}.json", "w") as outfile:
            for result in records:
                json.dump(result, outfile)
                outfile.write('\n')
        logger.info('json created')

    except:
        logging.exception("!!!json creation failed!!!")
        raise

def csv_creator(rows):
    f = StringIO()
    writer = csv.writer(f)
    for row in rows:
        lines = []

        for value in row["Data"]:

            if 'VarCharValue' in value.keys():
                lines.append(value["VarCharValue"])
            else:
                lines.append("")
        writer.writerow(lines)
    print("run csv")
    return f.getvalue()
    


def email(attachment, Query_Name, reciver_email, sender_email, region):
    x = datetime.datetime.now()
    month = x.month - 1
    csvfile = {
        "%s_%s.csv" % (Query_Name, month): attachment
    }  # name of file and content
    messege = build_email(
        Query_Name, "%s" % reciver_email, sender_email, attachments=csvfile
    )  # subject, to, from, file

    send_email(messege, region)
    print("run email")

# This is the standard boilerplate that calls the main() function.
def lambda_handler(event, context):
       
    Query_Name = event['Query_Name'] 
    project = event['GCP_Project']
    query = event["Query"] 

    prev = date.today().replace(day=1) - timedelta(days=1)
    month = prev.month
    year = prev.year

    if month < 10:
        bqmonth = f"0{month}"
    else:
        bqmonth = month

    records =  main(year, bqmonth, project, query)
    attachment = generate_csv(records)
    
    nlines = attachment.count('\n')
    if nlines > 1:
        email(attachment, Query_Name, Reciver_email, Sender_email, Region)
    else:
        print("Athena query returned no records")