import requests
from datetime import datetime, timedelta
import calendar
import argparse
import csv
import os
import boto3
import json
import logging


from lambda_base import generate_csv


def get_dates():
    date = (datetime.today() - timedelta(5))
    dateString = date.strftime("%Y-%m-%d")
    year = date.year
    month = date.month
    if month < 10:
        S3month = f"0{month}"
    day = date.day
    if day < 10:
        day = f"0{day}"
    return year, month, S3month, day, dateString


def split(daysInMonth, numOfGroups):
    quotient, remainder = divmod(len(daysInMonth), numOfGroups)
    return (daysInMonth[groupIndex * quotient + min(groupIndex, remainder):(groupIndex + 1) * quotient + min(groupIndex + 1, remainder)] for groupIndex in range(numOfGroups))


def sort(result, results, year, month):
    for item in result['data']:
        item.update({'month': month})
        item.update({'year': year})
        results.append(item)
    return results


def make_json(fileName, inputInformation, year, month, day, logger):
    logger.info("Creating json file")
    try:
        with open(f"/tmp/{fileName}", "w") as outfile:
            for result in inputInformation:
                json.dump(result, outfile)
                outfile.write('\n')
        logger.info('json created')
    except:
        logging.exception("!!!json creation failed!!!")
        raise


def lambda_handler(event, context):
    # initiate logging
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # initiate variables
    year, month, S3month, day, dateString = get_dates()

    fileName = f"{year}-{S3month}-{day}_azure_usage.json"
    accesskey = os.environ["API"]
    enrol = os.environ["ENROLMENT"]
    S3BucketName = os.environ["BUCKET_NAME"]

    headers_key = {"Authorization": f"Bearer {accesskey}"}
    response = requests.get(
        f"https://consumption.azure.com/v3/enrollments/{enrol}/usagedetailsbycustomdate?startTime={dateString}&endTime={dateString}",
        headers=headers_key,
    )

    results = []
    result = response.json()

    while result["nextLink"] is not None:

        results = sort(result, results, year, month)

        response = requests.get(result["nextLink"], headers=headers_key)

        result = response.json()

    results = sort(result, results, year, month)

    make_json(fileName, results, year, month, day, logger)

    logger.info("uploading json to S3")
    try:
        s3 = boto3.resource("s3")
        s3.meta.client.upload_file(
            f"/tmp/{fileName}", S3BucketName, f"Azure/year={year}/month={month}/{fileName}"
        )
        logger.info("Upload completed")
    except:
        logging.exception("!!!Upload Failed!!!")
        raise
