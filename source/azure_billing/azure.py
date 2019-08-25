import requests
import datetime
import calendar
import argparse
import csv
import os
import boto3
import json
import billing_email
from lambda_base import generate_csv

def date2(today):  # Gets todays date and the start date of the start of the month
    year = today.year
    month = today.month

    if month < 10:
        month = "0%s" % month

    start_date = "%s-%s-01" % (year, month)
    return start_date


def date():

    today = datetime.date.today()
    first = today.replace(day=1)
    lastMonth = first - datetime.timedelta(days=1)
    month = lastMonth.strftime("%m")
    year = lastMonth.strftime("%Y")
    return month, year

def sort(result, results, datee):
    for item in result['data']:
        del item['additionalInfo']
        del item['tags']
        item.update({'month':datee.month})
        item.update({'year':datee.year})
        results.append(item)
    return results

def bill():
    bucket_location = os.environ["BUCKET_LOCATION"]
    Region = os.environ["REGION"]
    Database = os.environ["DATABASE"]
    Tabel = os.environ["TABLE"]
    Query = os.environ["QUERY"]
    Query_Name = os.environ["QUERY_NAME"]
    emails = os.environ["EMAILS"]
    billing_email.main(bucket_location, Database, Tabel, Query, Query_Name, emails, Region)


def lambda_handler(event, context):
    month = ""
    month, year = date()

    if month != "":

        days = calendar.monthrange(int(year), int(month))[1]
        start_date = "%s-%s-01" % (int(year), int(month))
        end_date = "%s-%s-%s" % (int(year), int(month), days)

    else:
        end_date = datetime.date.today()
        start_date = date2(end_date)

    datee = datetime.datetime.strptime(start_date, "%Y-%m-%d")

    accesskey = os.environ["API"]
    enrol = os.environ["ENROLMENT"]
    S3BucketName = os.environ["BUCKET_NAME"]
    print(start_date, end_date)
    headers_key = {"Authorization": "Bearer %s" % accesskey}

    response = requests.get(
        "https://consumption.azure.com/v3/enrollments/%s/usagedetailsbycustomdate?startTime=%s&endTime=%s"
        % (enrol, start_date, end_date),
        headers=headers_key,
    )

    results = []
    result =response.json()

    while result["nextLink"] is not None:
        results = sort(result, results, datee)

        response = requests.get(result["nextLink"],headers=headers_key)
        result =response.json()

     
    results = sort(result, results, datee)

    csv = generate_csv(results, headings=['accountId', 'accountName','accountOwnerEmail', 'consumedQuantity', 'consumedService','consumedServiceId', 'cost','costCenter','date','departmentId','departmentName','instanceId', 'meterCategory','meterId','meterName','meterRegion','meterSubCategory','product','productId','resourceGroup','resourceLocation','resourceLocationId', 'resourceRate', 'serviceAdministratorId','serviceInfo1','serviceInfo2','storeServiceIdentifier', 'subscriptionGuid', 'subscriptionId', 'subscriptionName', 'unitOfMeasure', 'partNumber', 'resourceGuid', 'offerId','chargesBilledSeparately', 'location','serviceName','serviceTier','month','year'])

    file = open("/tmp/azure_usage.csv", "w")
    file.write(csv)
    file.close()

    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(
        "/tmp/azure_usage.csv", S3BucketName, "Azure/year=%s/month=%s/azure_usage.csv" %(datee.year, datee.month)
    )
    #bill()