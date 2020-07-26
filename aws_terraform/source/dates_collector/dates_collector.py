import logging
import os
from datetime import date, datetime, timedelta

import boto3
from botocore.exceptions import ClientError

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def sqs_message(client, queue_url, date_string):
    return client.send_message(
        QueueUrl=queue_url,
        MessageBody=date_string
    )


def daterange(first_date, last_date):
    for n in range(int((last_date - first_date).days) + 1):
        yield first_date + timedelta(n)

def first_and_last_dates():
    base = datetime.today().replace(day=1) - timedelta(1)
    dates = {"last_date": base, "first_date": base.replace(day=1)}
    LOGGER.info(dates)
    return dates


def lambda_handler(event, context):
    dates = first_and_last_dates()

    client = boto3.client('sqs')
    queue_url = os.environ['QUEUE_URL']

    for date in daterange(dates.get("first_date"), dates.get("last_date")):
        try:
            response = sqs_message(client, queue_url, date.strftime("%Y-%m-%d"))
            LOGGER.info(response)
        except ClientError as ce:
            raise ce
