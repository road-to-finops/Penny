import time
import boto3
import datetime
import json
from datetime import date, timedelta

# Use the temporary credentials that AssumeRole returns to make a
# connection to Amazon IAM



def append_data(check_name, team_info, resource, meta_result, month, year):

    temp = {}
    temp.update(check_name)
    temp.update(team_info)
    temp.update(resource)
    temp.update(meta_result)
    temp.update({'date':datetime.datetime.now().strftime('%Y-%m-%d')}) 
    return temp


def get_checks(team, account_id, client):
    today = date.today()
    year = today.year
    month = today.month


    result = []
    response = client.describe_trusted_advisor_checks(language="en")

    for case in response["checks"]:
        team_info = {"team": team, "account_id": account_id}
        meta = case["metadata"]
        if case["category"] == "cost_optimizing":
            c_id = case["id"]
            check_name = {"name": case["name"], "id": c_id}

            check_result = client.describe_trusted_advisor_check_result(
                checkId=c_id, language="en"
            )

            if check_result["result"]["status"] == "warning":
                flaggedResources = {
                    "flaggedResources": check_result["result"]["flaggedResources"]
                }

                for resource in flaggedResources.get("flaggedResources"):
                    meta_result = dict(zip(meta, resource["metadata"]))
                    updated = append_data(check_name, team_info, resource, meta_result, month, year)
                    del updated['metadata']
                    del updated['status']
                    result.append(updated)
    return result



if __name__ == "__main__":

    client = boto3.client("support", region_name="us-east-1")
    get_checks(None, None, client)
