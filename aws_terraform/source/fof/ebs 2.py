#!/usr/bin/env python3

import argparse
import boto3
from collections import defaultdict
import datetime
import boto3


def ebs(account_id, client):

    volume_list = []
    results = []
    response = client.describe_volumes()
    for result in response["Volumes"]:
        VolumeId = result["VolumeId"]
        Size = result["Size"]

        # for each ebs check if it is associated, if not give it the option to delete
        if len(result["Attachments"]) == 0:
            # print(VolumeId +" Size " + str(Size) +" is not associated with an EC2")
            volume_list.append(VolumeId)
            result = {
                "AccountId": account_id,
                "resource_id": VolumeId,
                "Product": "Volume",
            }
            results.append(result)
    # print(result)
    return results


if __name__ == "__main__":
    client = boto3.client("ec2")
    ebs("324382802360", client)
