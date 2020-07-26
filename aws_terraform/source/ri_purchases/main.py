import boto3
import time
import datetime
from dateutil.relativedelta import relativedelta
import csv
from io import StringIO
import rds_ri
import os
import emailer

def list_utilisation(listOfInstanceTypes, firstDay, lastDay):

    ce_client = boto3.client("ce")

    utilization = {}
    netrisavings = {}
    for instanceType in listOfInstanceTypes:
        response = ce_client.get_reservation_utilization(TimePeriod={
            'Start': firstDay,
            'End': lastDay
        },
            Filter={
            'Dimensions': {
                'Key': 'INSTANCE_TYPE',
                'Values': [
                    instanceType,
                ]
            }
        }
        )
        utilization.update(
            {instanceType: int(
                float(response['Total']['UtilizationPercentage']))},
        )
        netrisavings.update(
            {instanceType: int(float(response['Total']['NetRISavings']))},
        )
    return utilization, netrisavings


def list_instance_types(ri):
    listOfInstanceTypes = [reservation["InstanceType"] for reservation in ri]
    setOfInstanceTypes = set(listOfInstanceTypes)
    listOfUniqueInstanceTypes = list(setOfInstanceTypes)
    return listOfUniqueInstanceTypes

def ec2_ri():

    client = boto3.client("ec2")
    response = client.describe_reserved_instances()

    ri = response["ReservedInstances"]
    f = StringIO()
    fieldnames = [
        "InstanceType",
        "ProductDescription",
        "InstanceCount",
        "EndDate",
        "State",
        "PercentageUtilization",
        "LiveUsage",
        "NetRISavings"
    ]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()

    listOfInstanceTypes = list_instance_types(ri)

    now = time.localtime()
    lastDay = datetime.date(now.tm_year, now.tm_mon, 1) - datetime.timedelta(1)
    firstDay = str(lastDay.replace(day=1))
    lastDay = str(lastDay)

    instanceTypeUtalization, instanceTypeNetRISavings = list_utilisation(
        listOfInstanceTypes, firstDay, lastDay)

    live1 = datetime.datetime.strftime(
        datetime.datetime.now() - datetime.timedelta(3), '%Y-%m-%d')
    live2 = datetime.datetime.strftime(
        datetime.datetime.now() - datetime.timedelta(2), '%Y-%m-%d')
    instanceTypeUtalizationToday, empty = list_utilisation(
        listOfInstanceTypes, live1, live2)

    for reservation in ri:

        if reservation["State"] != "retired":
            InstanceType = reservation["InstanceType"]
            ProductDescription = reservation["ProductDescription"]
            InstanceCount = reservation["InstanceCount"]
            EndDate = reservation["End"]
            State = reservation["State"]
            PercentageUtilization = instanceTypeUtalization.get(InstanceType)
            LiveUsage = instanceTypeUtalizationToday.get(InstanceType)
            NetRISavings = instanceTypeNetRISavings.get(InstanceType)

            writer.writerow(
                {
                    "InstanceType": InstanceType,
                    "ProductDescription": ProductDescription,
                    "InstanceCount": InstanceCount,
                    "EndDate": EndDate,
                    "State": State,
                    "PercentageUtilization": PercentageUtilization,
                    "LiveUsage": round(int(InstanceCount) * int(LiveUsage) * 0.01),
                    "NetRISavings": NetRISavings
                }

            )

    return f.getvalue()


def lambda_handler(event, context):
    ec2_attachment = ec2_ri()
    rds_attachment = rds_ri.rds()

    emailer.Report(ec2_attachment, 'ec2_purchase')
    emailer.Report(rds_attachment, 'rds_purchase')
