import json
import logging
import os
from datetime import datetime, timedelta

import boto3
import requests
from lambda_base import generate_csv

# initiate logging
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def upload(s3_bucket_name, folder, file_name, year, month, bill_type):
    LOGGER.info(f"uploading {bill_type} json to S3")
    try:
        s3 = boto3.resource("s3")
        s3.meta.client.upload_file(
            f"/tmp/{file_name}",
            s3_bucket_name,
            f"Azure_Billing/{folder}/year={year}/month={month}/{file_name}",
        )
        LOGGER.info("Upload completed")
    except:
        logging.exception("!!!Upload Failed!!!")
        raise


def make_json(file_name, inputInformation, bill_type):
    LOGGER.info(f"Creating {bill_type} json file")
    try:
        with open(f"/tmp/{file_name}", "w") as outfile:
            for result in inputInformation:
                json.dump(result, outfile)
                outfile.write("\n")
        LOGGER.info("json created")
    except:
        logging.exception("!!!json creation failed!!!")
        raise


def sort(result, year, month):
    if "data" in result:
        for item in result["data"]:
            del item["additionalInfo"]
            del item["tags"]
            item.update({"month": month})
            item.update({"year": year})
    else:
        for item in result:
            item.pop("additionalInfo", None)
            item.pop("tags", None)
            item.update({"month": month})
            item.update({"year": year})
    return result


def get_billing_data(access_key, enrol, bill_types, s3_bucket_name, dates):
    day = dates.get("day")
    month = dates.get("month")
    year = dates.get("year")
    headers_key = {"Authorization": f"Bearer {access_key}"}

    for bill_type in bill_types:
        LOGGER.info(f"Getting billing data for {bill_type.get('billType')}")
        
        if bill_type["billType"] == "reservedInstances":
            file_name = f"{year}-{month}_azure_{bill_type.get('billType')}.json"
        else:
            file_name = f"{year}-{month}-{day}_azure_{bill_type.get('billType')}.json"
        
        # Azure enterprise portal API call
        try:
            LOGGER.info("start request")
            response = requests.get(
                f"https://consumption.azure.com/v3/enrollments/{enrol}/{bill_type.get('url')}",
                headers=headers_key,
            )
            response.raise_for_status()
            LOGGER.info("Data retrieved")
        except requests.exceptions.HTTPError as e:
            raise SystemExit(e)
        except requests.exceptions.Timeout as e:
            raise SystemExit(e)
        except requests.exceptions.RequestException as e:
            raise SystemExit(e)

        # if API request is succesfull retrive request body
        LOGGER.info(response)
        response = response.json()
        LOGGER.info(f"Number of items: {len(response)}")

        # if present handle pagination
        if "nextLink" in response:
            billing_data = []
            while response["nextLink"] is not None:

                billing_data.extend(sort(response.get("data"), year, month))

                response = requests.get(
                    response["nextLink"], headers=headers_key
                ).json()

        else:
            billing_data = sort(response, year, month)

        make_json(file_name, billing_data, bill_type.get("billType"))

        upload(
            s3_bucket_name,
            bill_type.get("s3Folder"),
            file_name,
            year,
            month,
            bill_type.get("billType"),
        )


def get_dates(date_string):
    LOGGER.info("Obtaining dates")
    date_string = date_string.split("-")
    return {
        "year": date_string[0],
        "month": date_string[1].lstrip("0"),
        "day": date_string[2].lstrip("0"),
    }


def lambda_handler(event, context):
    access_key = os.environ["API"]
    enrol = os.environ["ENROL"]
    s3_bucket_name = os.environ["BUCKET_NAME"]
    records = event["Records"]

    LOGGER.info(len(records))
    for record in records:
        date_string = record["body"]
        dates = get_dates(date_string)
        LOGGER.info(dates)
        bill_types = [
            {
                "billType": "usage",
                "url": f"usagedetailsbycustomdate?startTime={date_string}&endTime={date_string}",
                "s3Folder": "Azure_Usage",
            },
            {
                "billType": "marketplace",
                "url": f"marketplacechargesbycustomdate?startTime={date_string}&endTime={date_string}",
                "s3Folder": "Azure_Marketplace",
            },
        ]
        if dates["day"] == "1":
            bill_types.append(
                {
                    "billType": "reservedInstances",
                    "url": f"reservationcharges?startDate={date_string}&endDate={date_string}",
                    "s3Folder": "Azure_Reserved",
                }
            )
        LOGGER.info(bill_types)
        get_billing_data(access_key, enrol, bill_types, s3_bucket_name, dates)
