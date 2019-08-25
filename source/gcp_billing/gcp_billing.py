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

import sys
import os
import boto3
import json
import csv
from google.cloud import storage
from google.oauth2 import service_account
from google.cloud.exceptions import NotFound
from google.cloud.exceptions import Forbidden
import datetime
from datetime import date, timedelta


def key():
  
  key = json.loads(os.environ['API']) 

  with open(r"/tmp/key.text", "w") as out_file:
    json.dump(key, out_file)
    
  return 


def excel( yesterday):
  year = yesterday.year
  month = yesterday.month


  with open(r"/tmp/download_gcp-%s.csv"%yesterday) as in_file, open(
      r"/tmp/gcp-%s.csv"%yesterday, "w"
  ) as out_file:
      commaout = csv.reader(in_file, delimiter=",")
      semicolonin = csv.writer(out_file, delimiter=";")
      count = 0
      for row in commaout:
          if count ==0:
              row.append('month')
              row.append('year')
              semicolonin.writerow(row)
              print(row)
              count = count +1
          else:
              row.append(month)
              row.append(year)
              semicolonin.writerow(row)
              print(row)



def main(yesterday):

  # Make a list of command line arguments, omitting the [0] element
  # which is the script itself.

  bucket_name = "billing_data-193675"
  blob_name = 'gcp-%s.csv' %yesterday
  local_file_name = '/tmp/download_gcp-%s.csv' %yesterday

  key()

  print("got key")
  #credentials = service_account.Credentials.from_service_account_info(info)
  credentials = service_account.Credentials.from_service_account_file('/tmp/key.text')
  # Instantiate the client.
  client = storage.Client(project="billing-data-193675",credentials=credentials)
  print('Downloading an object from a Cloud Storage bucket to a local file ...')
  try:
    # Get the bucket.
    bucket = client.get_bucket(bucket_name)
    # Instantiate the object.
    blob = bucket.blob(blob_name)
    # Downloads an object from the bucket.
    blob.download_to_filename(local_file_name)
    print('\nDownloaded')
  except NotFound:
    print('Error: Bucket/Blob does NOT exists!!')
    pass
  except Forbidden:
    print('Error: Forbidden, you do not have access to it!!')
    pass

  return
    

# This is the standard boilerplate that calls the main() function.
def lambda_handler(event, context):
  S3BucketName = os.environ["S3_BUCKET_NAME"]

  today = date.today()
  yesterday = today - timedelta(days=1)
  year = today.year
  month = today.month
  main(yesterday)
  excel( yesterday)


  s3 = boto3.resource("s3")
  s3.meta.client.upload_file(
      "/tmp/gcp-%s.csv"%yesterday, S3BucketName, "GCP/year=%s/month=%s/gcp-%s.csv" %(year, month, yesterday)
  )