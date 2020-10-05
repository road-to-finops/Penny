import boto3
import json
from datetime import date, timedelta
import json
import os
import logging
from botocore.client import Config


def get_ec2_instance_recommendations(accountid, region):
    client = boto3.client('compute-optimizer', region_name=region)
    try:
        response = client.get_ec2_instance_recommendations(

            accountIds=[
                accountid,
            ]
        )
        
        data  = response['instanceRecommendations']
        
        return data
    except Exception as e:
                pass
                logging.warning(f"{e} - {accountid}")


def get_auto_scaling_group_recommendations(accountid, region):
    client = boto3.client('compute-optimizer', region_name=region)
    try:
        response = client.get_auto_scaling_group_recommendations(

            accountIds=[
                accountid,
            ]
        )
        data  = response['autoScalingGroupRecommendations']
        
        return data
    except Exception as e:
                pass
                logging.warning(f"{e} - {accountid}")



def write_file(file_name, data):
    with open('/tmp/%s.json' %file_name, 'w') as outfile:
     
        for item in data:
            if item is None or len(item) == 0:
                pass
            try:
                for instanceArn in item:
                    del instanceArn['lastRefreshTimestamp']
                    json.dump(instanceArn, outfile)
                    outfile.write('\n')
            except Exception as e:
                pass
                logging.warning("%s" % e)




def lambda_handler(event, context):
    ec2_reccomendations = []
    auto_scaling_group_recommendations= []
    Region = os.environ["REGION"]
    try:
        for record in event['Records']:
           
            account_id = record["body"]
            
            print(account_id)
            data = get_ec2_instance_recommendations(account_id, Region)
            ec2_reccomendations.append(data)
            
            auto_data = get_auto_scaling_group_recommendations(account_id, Region)
            auto_scaling_group_recommendations.append(auto_data)
    
            write_file('ec2_instance_recommendations' ,ec2_reccomendations)
            write_file('auto_scale_recommendations' ,auto_scaling_group_recommendations)

            today = date.today()
            year = today.year
            month = today.month

            S3BucketName = os.environ["BUCKET_NAME"]
            # uploads json to s3 bucket in customapps account
            s3 = boto3.client('s3', Region,
                            config=Config(s3={'addressing_style': 'path'}))
            s3.upload_file('/tmp/ec2_instance_recommendations.json', S3BucketName, "Compute_Optimizer/Compute_Optimizer_EC2/year=%s/month=%s/ec2_instance_recommendations_%s.json" %(year, month, account_id))
            print("ec2 data in s3")

            s3 = boto3.client('s3', Region,
                            config=Config(s3={'addressing_style': 'path'}))
            s3.upload_file('/tmp/auto_scale_recommendations.json', S3BucketName, "Compute_Optimizer/Compute_Optimizer_Auto_Scale/year=%s/month=%s/auto_scale_recommendations_%s.json" %(year, month, account_id))
            print("auto data in s3")
    except Exception as e:
        # Send some context about this error to Lambda Logs
        logging.warning("%s" % e)
    

