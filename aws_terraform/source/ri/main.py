import boto3
import os
import logging
import json
import pprint
import argparse
import csv
from botocore.exceptions import ClientError
from io import StringIO
from tenacity import retry, retry_if_exception_type, wait_exponential
from datetime import date, timedelta
import purchase_recom
import emailer


# service = "RDS"
pp = pprint.PrettyPrinter(indent=4)


def filters(file):
    # pass in ignor_accounts account numbers to remove from list so true data
    with open(file) as f:
        data = f.read().splitlines()
        return data


def Instance_Type(InstanceDetails):
    # finds instance types
    Instance_type = set([])
    for rec in InstanceDetails:
        Instance_type.add(rec["InstanceType"])
    return Instance_type


def Platform(Eng, InstanceDetails):
    # finds linux/windows
    Platform = set([])
    for rec in InstanceDetails:
        Platform.add(rec[Eng])
    return Platform
    
def Tenancy(InstanceDetails):
    # finds Tenancy
    Tenancys = set([])
    for rec in InstanceDetails:
        Tenancys.add(rec["Tenancy"])
    return Tenancys

def DeploymentOption(InstanceDetails):
    # finds DeploymentOption
    DeploymentOptions = set([])
    for rec in InstanceDetails:
        DeploymentOptions.add(rec["DeploymentOption"])
    return DeploymentOptions

def filter_response(service):
    InstanceDetails = {}
    InstanceList = []

    closed_account_list = filters("ignor_accounts.txt")
    ignor_instance_types = filters("ignor_instance_types.txt")
    ignor_platformss = filters("ignor_platforms.txt")

    if service == "EC2":
        reccomeded_ri = purchase_recom.ec2_reccomeded_ri("LINKED")
        Eng = "Platform"
        details = "EC2InstanceDetails"

    elif service == "RDS":
        reccomeded_ri = purchase_recom.rds_reccomeded_ri("LINKED")
        Eng = "DatabaseEngine"
        details = "RDSInstanceDetails"

    else:
        print("Hit by a bludger")  # does not work
        exit

    data = json.dumps(reccomeded_ri)
    dictonary = json.loads(data)
    # Cleans out reccomendations for accounts and versions we dont care about
    try:
        for item in dictonary["Recommendations"]:

            for result in item["RecommendationDetails"]:
                InstanceDetails = {}

                AccountId = result["AccountId"]
                InstanceType = result["InstanceDetails"][details]["InstanceType"]
                Recommendation_number = result["RecommendedNumberOfInstancesToPurchase"]

                Region = result["InstanceDetails"][details]["Region"]

                Platform = result["InstanceDetails"][details][Eng]

                if AccountId in closed_account_list:
                    pass
                elif InstanceType in ignor_instance_types:
                    pass
                elif Platform in ignor_platformss:
                    pass
                elif Region != "EU (Ireland)":
                    pass
                else:
                    InstanceDetails.update(result["InstanceDetails"][details])
                    InstanceDetails[
                        "RecommendedNumberOfInstancesToPurchase"
                    ] = Recommendation_number

                    InstanceList.append(InstanceDetails)

        return InstanceList
    except:
        print("none")
        return None


def combine_reccomendation(service):
    reccomendation = []
    instance_details = filter_response(service) # gets rid of accounts, types, os we dont care about. These can be edited in the text files
    instance_type = Instance_Type(instance_details) # gets the relevent insatces types for RDS or EC2
    if service == "EC2":
        Eng = "Platform"
        DeploymentOptions = Tenancy(instance_details) # gets tency e.g. shared
        Option = "Tenancy"
    elif service == "RDS":
        Eng = "DatabaseEngine"
        Option = "DeploymentOption"
        DeploymentOptions = DeploymentOption(instance_details)# gets Deployment e.g. Single AZ
    platforms = Platform(Eng, instance_details)

    # used Deployment as a base to combine results. the idea being we check for Deployment, os, instacnce type and then comebine reulst for all accounts
    for option in DeploymentOptions:
        for os in platforms:
            for in_type in instance_type:
                counter = 0
                for rec in instance_details:
                    if (
                        rec[Eng] == os
                        and rec["InstanceType"] == in_type
                        and rec[Option] == option
                    ):
                        counter += int(rec["RecommendedNumberOfInstancesToPurchase"])
                    # this is for cases were types are for one platform not the other
                if counter != 0:
                    reccomendation.append( # turn into a smaller set of json data
                        {
                            "Instance_Type": in_type,
                            "Eng": os,
                            "Number": counter,
                            "DeploymentOption": option,
                        }
                    )
    return reccomendation



def lambda_handler(event, context):

    today = date.today()
    year = today.year
    month = today.month
    S3BucketName = os.environ["BUCKET"]
    
    service = "EC2"  
    reccomendation = combine_reccomendation(service)
    ec2_reccomeded_ri = purchase_recom.risk(reccomendation, service)

    file = open("/tmp/ec2_ri.json", "w")
    file.write(str(ec2_reccomeded_ri))
    file.close()

    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(
        "/tmp/ec2_ri.json",
        S3BucketName,
        "RI/year=%s/month=%s/ec2_ri.json" % (year, month),
    )
    print("EC2 done")

    service = "RDS"
    reccomendation = combine_reccomendation(service)
    rds_reccomeded_ri = purchase_recom.risk(reccomendation, service)

    file = open("/tmp/rds_ri.json", "w")
    file.write(str(rds_reccomeded_ri))
    file.close()

    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(
        "/tmp/rds_ri.json",
        S3BucketName,
        "RI/year=%s/month=%s/rds_ri.json" % (year, month),
    )
    print("RDS done")

    emailer.Report(ec2_reccomeded_ri, 'ec2')
    emailer.Report(rds_reccomeded_ri, 'rds')

    print("Email done")