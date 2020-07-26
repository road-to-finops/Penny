import boto3
from botocore.exceptions import ClientError


def free_elastic_ip(account, client):
    results = []
    response = client.describe_addresses()
    # for each ip check if it is associated, if it is move on
    for address in response["Addresses"]:
        if address.get("AssociationId") is None:
            elastic_ip = address["PublicIp"]

            result = {
                "AccountId": account,
                "resource_id": elastic_ip,
                "Product": "Elastic IP",
            }
            results.append(result)
    return results


if __name__ == "__main__":
    client = boto3.client("ec2")
    free_elastic_ip(None, client)
