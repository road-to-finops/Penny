#!/usr/bin/env python3

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
    assume_role,
    format_arn,
    logger,
    generate_csv,
)
from io import StringIO
from tenacity import retry, retry_if_exception_type, wait_exponential

log = logging.getLogger()
def athena_query(bucket_location, Database, Query, client):
    
    log.info("Making Athena Query")

    ExecutionId = client.start_query_execution(
        QueryString=Query,
        QueryExecutionContext={"Database": Database},
        ResultConfiguration={
            "OutputLocation": bucket_location,
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
def results(QueryExecutionId, client):
    print("pre rows")
    log.info(f"Getting results from: {QueryExecutionId}")

    results = client.get_query_results(QueryExecutionId=QueryExecutionId)

    ResultSet = results.get("ResultSet")
   
    rows = ResultSet.get("Rows")

    return rows


def csv_creator(rows):
    f = StringIO()
    writer = csv.writer(f)
   # import pdb; pdb.set_trace()
    for row in rows:
        lines=[]
        #writer.writerow([if value["VarCharValue"] not none  for value in row["Data"]])
        
        for value in row["Data"]:
            #if value["VarCharValue"] is not None:
            
            if 'VarCharValue' in value.keys():
                lines.append(value["VarCharValue"])
            else:
                #import pdb; pdb.set_trace()
                lines.append("")
        writer.writerow(lines)
    return f.getvalue()
    print("run csv")

    


def email(attachment, Query_Name, emails):
    x = datetime.datetime.now()
    month = x.month - 1
    role_arn = format_arn(
        service="iam",
        account_id="165293267760",
        resource_type="role",
        resource="Billing_Role",
    )  # generates valid ARN from AWS
    customapps_session = assume_role(role_arn, Query_Name)  # similar to boto3 client

    csvfile = {
        "%s_%s.csv" % (Query_Name, month): attachment
    }  # name of file and content
    messege = build_email(
        Query_Name, "%s" % emails, "billing@cloud-ops.co.uk", attachments=csvfile
    )   #subject, to, from, file

    send_email(messege, "eu-west-1", customapps_session)
    print("run email")


def main(bucket_location, Database, Tabel, Query, Query_Name, emails, Region):
    client = boto3.client("athena", region_name=Region)
    log = logging.getLogger()
    QueryExecutionId = athena_query(bucket_location, Database, Query, client)
    log.info(f"Got execution_id: {QueryExecutionId}")
    rows = results(QueryExecutionId, client)
    attachment = csv_creator(rows)
    email(attachment, Query_Name, emails)
