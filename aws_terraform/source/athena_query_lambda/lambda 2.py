import boto3
import time
import csv
import json
import logging
import os
import datetime
from lambda_base import (
    build_email,
    send_email,
    format_arn,
    generate_csv,
)
from io import StringIO
from tenacity import retry, retry_if_exception_type, wait_exponential

Region = os.environ["REGION"]
Sender_email = os.environ["SENDEREMAIL"]
Reciver_email = os.environ["RECIVEREMAIL"]

log = logging.getLogger()
client = boto3.client("athena", region_name=Region)


def athena_query(Query, Query_Name, Database, Bucket):
    log.info("Making Athena Query")
    Bucket_Location = f"s3://{Bucket}/athena/{Query_Name}"
    QueryString = Query.replace('Database_Value', Database)

    ExecutionId = client.start_query_execution(
        QueryString=QueryString,
        QueryExecutionContext={"Database": Database},
        ResultConfiguration={
            "OutputLocation": Bucket_Location,
            "EncryptionConfiguration": {"EncryptionOption": "SSE_S3"},
        },
    )

    return ExecutionId.get("QueryExecutionId")


@retry(
    retry=retry_if_exception_type(
        boto3.client("athena").exceptions.InvalidRequestException
    ),
    wait=wait_exponential(multiplier=1, max=10),
)
def results(QueryExecutionId):

    print("pre rows")
    log.info(f"Getting results from: {QueryExecutionId}")
    results = client.get_query_results(QueryExecutionId=QueryExecutionId)
    try:
        ResultSet = results.get("ResultSet")
        rows = ResultSet.get("Rows")

    except:
        log.info(f"No results from: {QueryExecutionId}")
        rows = ""
    return rows


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
        Query_Name, "%s" % reciver_email, Sender_email, attachments=csvfile
    )  # subject, to, from, file

    send_email(messege, region)
    print("run email")


def lambda_handler(event, context):
    Query = event['Query']
    Database = event['Database']
    Query_Name = event['Query_Name']
    Bucket = event['Bucket']
    Env = event['Env']
    Query_Type = event['Query_Type']

    QueryExecutionId = athena_query(Query, Query_Name, Database, Bucket)
    log.info(f"Got execution_id: {QueryExecutionId}")
    rows = results(QueryExecutionId)
    attachment = csv_creator(rows)
    nlines = attachment.count('\n')
    if nlines > 1:
        email(attachment, Query_Name, Reciver_email, Sender_email, Region)
    else:
        log.info("Athena query returned no records")
        if Query_Type == "finops_bill":
            raise AttributeError(
                f"FinOps billing event ({Query_Name}) did not send report as Athena Query returned no records")
    print(f"{Query_Name} Complete")
