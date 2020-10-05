import requests
import json
import os
import csv
import boto3
from lambda_base import generate_csv
from tqdm import tqdm
from flatten_dict import flatten
from datetime import date, timedelta

def auth(tenant, password, username):
    client_id = os.environ["CLIENT_ID"]
    keys = {
        "resource": "https://management.azure.com/",
        "username": username,
        "password": password,
        "grant_type": "password",
        "client_id": client_id,
    }

    headers_key = {"Content-Type": "application/x-www-form-urlencoded"}

    response = requests.post(
        "https://login.microsoftonline.com/%s/oauth2/token/" % tenant,
        data=keys,
        headers=headers_key,
    )
    r = json.loads(response.text)

    token = r.get("access_token")
    return token


def tenants(headers_key):
    tenant_ids = []
    response = requests.get(
        "https://management.azure.com/tenants?api-version=2016-06-01",
        headers=headers_key,
    )
    tenant_list = json.loads(response.text)
    tenant = tenant_list.get("value")
    for tenant_id in tenant:
        tenant_ids.append(tenant_id["tenantId"])

    return tenant_ids

def subscriptions(headers_key):
    subscription_ids = []
    response = requests.get(
        "https://management.azure.com/subscriptions?api-version=2016-06-01",
        headers=headers_key,
    )
    sub_list = json.loads(response.text)

    subs = sub_list.get("value")
    for sub_id in subs:
        subscription_ids.append(sub_id["subscriptionId"])
    return subscription_ids


def lambda_handler(event, context):
    password = os.environ["PASSWORD"]
    S3BucketName = os.environ["BUCKET_NAME"]
    username = os.environ["USERNAME"]
    tenant = os.environ["TENANT"]

    token = auth(tenant, password, username)
    result = []
    results = []
    headers_key = {"Authorization": "Bearer %s" % token}

    tenant_ids = tenants(headers_key)

    for tenant in tqdm(tenant_ids):
        token = auth(tenant, password, username)
        headers_key = {"Authorization": "Bearer %s" % token}
        subs = subscriptions(headers_key)

        for subscription in subs:
            response = requests.get(
                "https://management.azure.com/subscriptions/%s/providers/Microsoft.Advisor/recommendations?api-version=2017-04-19"
                % subscription,
                headers=headers_key,
            )

            advisor = json.loads(response.text)

            reccomedation = advisor.get("value")
            for item in reccomedation:
                
                if item["properties"]["category"] == "Cost":
                    subscription_id = {"subscription": subscription}
                    subscription_id.update(item["properties"])
                    result.append(subscription_id)

    for item in result:
        
        results.append(flatten(item, reducer="path"))

    csv = generate_csv(results, headings=['subscription', 'category', 'impact', 'impactedField', 'impactedValue',  'lastUpdated', 'recommendationTypeId', 'shortDescription', 'shortDescription/problem','shortDescription/solution', 'extendedProperties', 'extendedProperties/deploymentId', 'extendedProperties/roleName',  'extendedProperties/location', 'extendedProperties/annualSavingsAmount', 'extendedProperties/savingsAmount', 'extendedProperties/savingsCurrency', 'extendedProperties/term', 'extendedProperties/reservationType','extendedProperties/scope', 'extendedProperties/targetResourceCount', 'extendedProperties/savingsPercentage', 'extendedProperties/vmSize' ])

    today = date.today()
    year = today.year
    month = today.month

    file = open("/tmp/azure_advisor.csv", "w")
    file.write(csv)
    file.close()

    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(
        "/tmp/azure_advisor.csv", S3BucketName, "Azure_Advisor/year=%s/month=%s/azure_advisor_%s_%s.csv" %(year, month, month, year)
    )
