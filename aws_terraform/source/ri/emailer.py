#!/usr/bin/env python3
# -*- coding: utf-8 -*-


__author__ = "Na Zhang"
__version__ = "v1.0"

import boto3
import botocore
import json
import time
import os
import sys
import datetime
from datetime import date
import re
import signal
import csv_generator

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), "./package"))


# email lib
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import COMMASPACE, formatdate
from botocore.exceptions import ClientError

# optional - match sheetname to add chart
sheetNameMOM = "MoM_Inter_AZ_DT_Chart"
# sheetNameWOW = "Inter_AZ_DT_WOW_Chart"

# temp path for converting csv to xlsx file, adding graph, and combining mulitple files to single one
tempPath = "/tmp"
# Expiration time for checking Athena query status, default value is 180 seconds
queryExpiration = 180

# print curBucket
# print curKeyPath


# Get current year, month and week
curYear = datetime.datetime.now().year
curMonth = datetime.datetime.now().month
# if current month is Jan or Feb, set last year/month (and previous last month) correctly as report provides data in the past three months
if curMonth == 1:
    curOrLastYr = curYear - 1
    lastYear = curYear - 1
    lastMon = 12
    preLastMon = 11
elif curMonth == 2:
    curOrLastYr = curYear
    lastYear = curYear - 1
    lastMon = 1
    preLastMon = 12
else:
    curOrLastYr = curYear
    lastYear = curYear
    lastMon = curMonth - 1
    preLastMon = curMonth - 2

# Define a dic list qStrList, and load all query strings into qStrList with the pair key (Name, queryString), also replace year/month in the strings
# print(qStr[0].values()[0])
qStrList = []
# Multiple charactors replacement in a string


# Recursively load query status untill all query status is SUCCEEDED
def checkQueryExecution(queryIdList):
    client = boto3.client("athena")
    resp = client.batch_get_query_execution(QueryExecutionIds=queryIdList)
    query_execution = resp["QueryExecutions"]
    unfinishedList = []
    for query in query_execution:
        print(query["QueryExecutionId"], query["Status"]["State"])
        if query["Status"]["State"] != "SUCCEEDED":
            unfinishedList.append(query["QueryExecutionId"])
    if len(unfinishedList) == 0:
        print("All queries are succeed")
        return "Succeed"
    else:
        time.sleep(10)
        checkQueryExecution(unfinishedList)


# Add graph for monthly or weekly trend data
def addChart(writer, sheetName, rowIndex):
    workbook = writer.book
    worksheet = writer.sheets[sheetName]
    if sheetName == sheetNameMOM:
        print("Add graph for sheet " + sheetNameMOM)
        chart = workbook.add_chart({"type": "column"})
        chart.add_series(
            {
                "name": "Usage Month Trend(GB)",
                "categories": [sheetName, 1, 1, rowIndex, 1],
                "values": [sheetName, 1, 2, rowIndex, 2],
            }
        )
        # Insert the chart into the worksheet.
        worksheet.insert_chart("C8", chart)



# Send CUR report via SES
def sendReport(sesRegion, sesSub, sesSender, sesReceiver, sesReportName, sesBody):
    
    os.chdir(tempPath)
    print("Sending report via SES... ")
    client = boto3.client("ses", region_name=sesRegion)
    # Create a multipart/mixed parent container.
    msg = MIMEMultipart("mixed")
    # Add subject, from and to lines.
    msg["Subject"] = sesSub
    msg["From"] = sesSender
    msg["To"] = sesReceiver
    # Define the attachment part and encode it using MIMEApplication.
    att = MIMEApplication(open(sesReportName, "rb").read())
    # Add a header to tell the email client to treat this part as an attachment,
    # and to give the attachment a name.
    att.add_header(
        "Content-Disposition", "attachment", filename=os.path.basename(sesReportName)
    )
    # Add the attachment to the parent container.
    msg.attach(att)
    msg.attach(MIMEText(sesBody))
    # print(msg)
    try:
        # Provide the contents of the email.
        response = client.send_raw_email(
            Source=sesSender,
            Destinations=sesReceiver.split(","),
            RawMessage={"Data": msg.as_string()},
        )
        return response
    # Display an error if something goes wrong.
    except ClientError as e:
        print(e.response["Error"]["Message"])

    else:
        print("Email sent! Message ID:"),
        print(response["MessageId"])


# =========== Function Execution ==================
def Report(qStrList, name):
    
# sendReport(region,subject,sender,recipient,curReportName,bodyText)
    Sender_email = os.environ["SENDEREMAIL"]
    Reciver_email = os.environ["RECIVEREMAIL"]
    Region = os.environ["REGION"]
    
    attach_file = csv_generator.generate_csv(qStrList)
    
    file = open("/tmp/%s.csv" %name, "w")
    file.write(str(attach_file))
    file.close()
    #sendReport(region,subject,sender,recipient,curReportName,bodyText)
    response = sendReport(Region, 'ri recommendations', Sender_email, Reciver_email, '%s.csv' %name, 'This is a set of RI recommendations for %s' %name)
    return response

