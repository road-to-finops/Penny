import boto3
import pdb

#


def extra_cloudtrail(account_id, client):
    results = []
    cloudtrails = client.describe_trails(includeShadowTrails=True)

    for trails in cloudtrails["trailList"]:
        if trails["IsOrganizationTrail"] is False:

            trail_name = trails["Name"]
            s3 = trails["S3BucketName"]
            result = {
                "AccountId": account_id,
                "resource_id": trail_name,
                "Product": "AWSCloudTrail",
            }
            results.append(result)
            result2 = {
                "AccountId": account_id,
                "resource_id": s3,
                "Product": "AWSCloudTrail_bucket",
            }
            results.append(result2)
    return results


if __name__ == "__main__":
    client = boto3.client("cloudtrail")
    extra_cloudtrail(None, client)
