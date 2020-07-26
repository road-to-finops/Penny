import boto3
import datetime
import logging
import os


logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def check(response, time_interval, account_id):
    snap_list = []
    for snapshot in response["Snapshots"]:

        time_difference = str(
            datetime.datetime.now() - snapshot["StartTime"].replace(tzinfo=None)
        ).split(" ")
        # format(snapshot['SnapshotId'], time_difference[0]))
        if len(time_difference) > 1 and int(time_difference[0]) >= time_interval:
            snp = snapshot["SnapshotId"]
            # print('%s:%s' %(snp, time_difference))
            snap_list.append(snp)
    result = {
        "AccountId": account_id,
        "resource_id": snap_list,
        "Product": "Storage Snapshot",
    }

    # print(result)
    return result


def snapshot(account_id, client):

    response = client.describe_snapshots()
    check(response, 30, account_id)


if __name__ == "__main__":
    client = boto3.client("ec2")
    snapshot(None, client)
