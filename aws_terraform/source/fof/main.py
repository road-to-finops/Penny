#!/usr/bin/env python3
import logging
import boto3
from botocore.exceptions import ClientError
from tqdm import tqdm
from datetime import date
import os
import json
import argparse
import datetime
import elb
import eip
import ec2
import ebs
import snapshot
import cloudtrail


def configure_parser():
    #used if need to check in one account, mostly for testing
    parser = argparse.ArgumentParser(description="Identify idle/unused resource")
    parser.add_argument("-a", help="account id")

    args = parser.parse_args()
    account = args.a
    return account


def assume_role(account_id, service, region):

    role_arn = "arn:aws:iam::%s:role/OrganizationAccountAccessRole" % account_id
    sts_client = boto3.client("sts")
    if region is None:
        region = sts_client.meta.region_name

    try:

        assumedRoleObject = sts_client.assume_role(
            RoleArn=role_arn, RoleSessionName="AssumeRoleRoot"
        )

        credentials = assumedRoleObject["Credentials"]
        client = boto3.client(
            service,
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
            region_name=region,
        )
        return client

    except ClientError as e:
        logging.warning("Unexpected error Account %s: %s" % (account_id, e))
        return None


def org_accounts():
    try:
        client = boto3.client("organizations", region_name="us-east-1")
        paginator = client.get_paginator("list_accounts")
        response_iterator = paginator.paginate()
        return response_iterator
    except:
        pass


def lambda_handler(event, context):
    bucket = os.environ["BUCKET"]
    account_passin = configure_parser()
    # initiate logging
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # collects date info for s3 placement
    today = date.today()
    year = today.year
    month = today.month
    region = os.environ["REGION"]

    method_list = ["elb", "alb", "eip", "stopped_ec2", "cloudtrail", "ebs"]
    result = []
    accountInfo = org_accounts()
    

    if account_passin is not None:
        accountInfo = [
            {"Accounts": [{"Id": "%s" % account_passin, "Status": "ACTIVE"}]}
        ]
    else:
        pass

    for method in tqdm(method_list):
        for response in accountInfo:
            for account in response["Accounts"]:
                account_id = account["Id"]
                # check not closed as connot access this
                if account["Status"] == "ACTIVE":
                    try:
                        if method == "eip":
                            client = assume_role(account_id, "ec2", region)
                            result.append(eip.free_elastic_ip(account_id, client))
                            # works
                        elif method == "stopped_ec2":
                            client = assume_role(account_id, "ec2", region)
                            result.append(ec2.stopped_ec2(account_id, client))
                            # works
                        elif method == "elb":
                            client = assume_role(account_id, "elb", region)
                            result.append(elb.classic_elb(account_id, client))
                            # works
                        elif method == "alb":
                            client = assume_role(account_id, "elbv2", region)
                            result.append(elb.app_elb(account_id, client))
                            # works
                        elif method == "cloudtrail":
                            client = assume_role(account_id, "cloudtrail", region)
                            result.append(
                                cloudtrail.extra_cloudtrail(account_id, client)
                            )
                            # works
                        elif method == "ebs":
                            client = assume_role(account_id, "ec2", region)
                            result.append(ebs.ebs(account_id, client))
                            # works
                        elif method == "snapshot":
                            client = assume_role(account_id, "ec2", region)
                            result.append(snapshot.snapshot(account_id, client))
                    except Exception as e:
                        pass
                        logging.warning("%s" % e)
                else:
                    logger.info("%s is not active in org" % account_id)
        test = []

        for item in result:
            for item2 in item:
                item2.update({"Info": "waste"})
                item2.update({"Date": datetime.datetime.now().strftime("%Y-%m-%d")})
                item2.update({"Month": month})
                item2.update({"Year": year})
                test.append(item2)

    # writes per item in list of data
    with open("/tmp/FOF.json", "w") as outfile:
        for result in test:
            json.dump(result, outfile)
            outfile.write("\n")

    # uploads to s3
    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(
        "/tmp/FOF.json",
        bucket,
        "FinOpsFinder/year=%s/month=%s/FOF_%s_%s.json" % (year, month, month, year),
    )

