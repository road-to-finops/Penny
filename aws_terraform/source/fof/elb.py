import boto3
from botocore.exceptions import ClientError
import pdb


def classic_elb(account, client):
    elb_list = []
    results = []
    lbs = client.describe_load_balancers()

    for classic_elb in lbs["LoadBalancerDescriptions"]:
        elb_name = classic_elb["LoadBalancerName"]
        instance_health = client.describe_instance_health(LoadBalancerName=elb_name)
        if instance_health["InstanceStates"] == []:
            elb_list.append(elb_name)

            result = {
                "AccountId": account,
                "resource_id": elb_name,
                "Product": "Load Balancer",
            }
            results.append(result)
    return results


def app_elb(account, client):
    results = []
    alb_list = []
    lbs = client.describe_load_balancers()
    for application_elb in lbs["LoadBalancers"]:
        alb_arn = application_elb["LoadBalancerArn"]

        target_groups = client.describe_target_groups(LoadBalancerArn=alb_arn)
        for targetgroup in target_groups["TargetGroups"]:
            targetgroup_arn = targetgroup["TargetGroupArn"]

            response = client.describe_target_health(TargetGroupArn=targetgroup_arn)
            if response["TargetHealthDescriptions"] == []:
                # print('%s is empty' %alb_arn)
                alb_list.append(alb_arn)
                result = {
                    "AccountId": account,
                    "resource_id": alb_arn,
                    "Product": "Load Balancer",
                }
                results.append(result)

    return results
    """
    else:
        for TargetHealthDescriptions in response['TargetHealthDescriptions']:
            TargetHealth = TargetHealthDescriptions['TargetHealth']
            if TargetHealth['State'] == 'unhealthy':
                print('%s is unhealth' %alb_arn)
    """


if __name__ == "__main__":
    client = boto3.client("elb")
    classic_elb(None, client)
