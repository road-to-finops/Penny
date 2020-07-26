import boto3
import botocore.session
import os
from datetime import datetime


def create_data_source(client, AwsAccountId, DataSourceId, UserArn):
    print("Creating datasource: ")
    response = client.create_data_source(
        AwsAccountId=AwsAccountId,
        DataSourceId=DataSourceId,
        Name=DataSourceId,
        Type="ATHENA",
        DataSourceParameters={"AthenaParameters": {"WorkGroup": "primary"}},
        Permissions=[
            {
                "Principal": UserArn,
                "Actions": [
                    "quicksight:DescribeDataSource",
                    "quicksight:DescribeDataSourcePermissions",
                    "quicksight:PassDataSource",
                ],
            }
        ],
        Tags=[{"Key": "Project", "Value": "Penny"}],
    )
    print(response["DataSourceId"])
    return response["Arn"]


def DataSet_RelationalTable(
    AccountId, client, DataSourceArn, AthenaDatabase, AthenaTable, DataSetId, UserArn
):
    # =====RelationalTable======

    print("Creating dataset: ")

    response = client.create_data_set(
        AwsAccountId=AccountId,
        DataSetId=DataSetId,
        Name=DataSetId,
        PhysicalTableMap={
            "Testing": {
                "RelationalTable": {
                    "DataSourceArn": DataSourceArn,
                    "Name": AthenaTable,
                    "Schema": AthenaDatabase,
                    "InputColumns": [{"Name": "identity_lineitemid", "Type": "STRING"}],
                }
            }
        },
        ImportMode="SPICE",
        Permissions=[
            {
                "Principal": UserArn,
                "Actions": [
                    "quicksight:DescribeDataSet",
                    "quicksight:DescribeDataSetPermissions",
                    "quicksight:PassDataSet",
                    "quicksight:DescribeIngestion",
                    "quicksight:ListIngestions",
                    "quicksight:UpdateDataSet",
                    "quicksight:DeleteDataSet",
                    "quicksight:CreateIngestion",
                    "quicksight:CancelIngestion",
                    "quicksight:UpdateDataSetPermissions",
                ],
            }
        ],
        Tags=[{"Key": "Project", "Value": "Penny"}],
    )
    print(response["DataSetId"])
    return response["Arn"]


def lambda_handler(event, context):

    session = botocore.session.get_session()
    Region = os.environ["REGION"]

    client = session.create_client("quicksight", region_name=Region)

    AwsAccountId = os.environ["ACCOUNT_ID"]
    DataSourceId = os.environ["DATA_SOURCE_ID"]
    DataSetId = os.environ["DATA_SET_ID"]
    AthenaDatabase = os.environ["ATHENA_DATABASE"]
    AthenaTable = os.environ["ATHENA_TABLE"]
    UserArn =os.environ["USER_ARN"] 
    data_source_arn = create_data_source(client, AwsAccountId, DataSourceId, UserArn)

    DataSet_RelationalTable(
        AwsAccountId, client, data_source_arn, AthenaDatabase, AthenaTable, DataSetId, UserArn
    )
