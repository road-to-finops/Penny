import boto3
import datetime
import csv
from io import StringIO


def rds():
    client = boto3.client("rds")
    response = client.describe_reserved_db_instances()

    ri = response["ReservedDBInstances"]

    f = StringIO()
    fieldnames = [
        "DBInstanceClass",
        "ProductDescription",
        "MultiAZ",
        "DBInstanceCount",
        "StartTime",
    ]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()

    for reservation in ri:
        if reservation["State"] != "retired":
            DBInstanceClass = reservation["DBInstanceClass"]
            ProductDescription = reservation["ProductDescription"]
            MultiAZ = reservation["MultiAZ"]
            DBInstanceCount = reservation["DBInstanceCount"]
            StartTime = reservation["StartTime"]

            writer.writerow(
                {
                    "DBInstanceClass": DBInstanceClass,
                    "ProductDescription": ProductDescription,
                    "MultiAZ": MultiAZ,
                    "DBInstanceCount": DBInstanceCount,
                    "StartTime": StartTime,
                }
            )

    return f.getvalue()


if __name__ == "__main__":
    print(rds())
