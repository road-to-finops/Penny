#!/usr/bin/env python3

import argparse
import boto3
from botocore.exceptions import ClientError

import eip
import ec2


def configure_parser():
    parser = argparse.ArgumentParser(description="Identify idle/unused EBS volumes")
    parser.add_argument(
        "-m",
        required=True,
        choices=["eip", "stopped_ec2"],
        help="which function do you want to use",
    )
    args = parser.parse_args()

    # global method
    method = args.m
    return method


def list_accounts():
    client = boto3.client("organizations", region_name="us-east-1")
    paginator = client.get_paginator("list_accounts")
    response_iterator = paginator.paginate()
    # account_ids = [account["Id"] for response in response_iterator for account in response["Accounts"] if account["Status"] != "SUSPENDED"]
    for response in response_iterator:
        for account in response["Accounts"]:
            # if account["Status"] != "SUSPENDED":
            print(account["Id"], ",", account["Name"], ",", account["JoinedTimestamp"])

    # return account_ids


def assume_role(account_id):

    full_ip_list = []
    role_arn = "arn:aws:iam::%s:role/RootAccountAdmin" % account_id
    sts_client = boto3.client("sts")
    try:
        assumedRoleObject = sts_client.assume_role(
            RoleArn=role_arn, RoleSessionName="AssumeRoleRoot"
        )

        credentials = assumedRoleObject["Credentials"]
        client = boto3.client(
            "ec2",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        return client

    except ClientError as e:
        print("Unexpected error: %s" % e)
        return None


def main():
    method = configure_parser()

    Account_IDs = list_accounts()
    s_list = []
    for account_id in Account_IDs:

        try:
            client = assume_role(account_id)
            if method == "eip":
                print(eip.free_elastic_ip(account_id, client))
            elif method == "stopped_ec2":
                stopped = ec2.stopped_ec2(account_id, client)
                s_list.append(stopped)
                print(stopped)

        except Exception as e:
            print(e)

    print(s_list)


if __name__ == "__main__":
    list_accounts()
