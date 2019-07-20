import boto3
import os
import logging
import json
import pprint
import argparse
from botocore.exceptions import ClientError

import purchase_recom

'''
parser = argparse.ArgumentParser(description='AWS RI reccomendations')
parser.add_argument('-service', required=True, choices=['EC2','RDS'], help='Which service would you like RIs for')
args = parser.parse_args()
service = args.service
'''
service = "EC2"
pp = pprint.PrettyPrinter(indent=4)

def filters(file):
    #pass in ignor_accounts account numbers to remove from list so true data
    with open(file) as f:
        data = f.read().splitlines()
        return data


def Instance_Type(InstanceDetails):
    #finds instance types
    Instance_type =  set([])   
    for rec in InstanceDetails:
        Instance_type.add(rec['InstanceType'])
    return Instance_type

def Platform(Eng,InstanceDetails):
    #finds linux/windows
    Platform =  set([])   
    for rec in InstanceDetails:
        Platform.add(rec[Eng])
    return Platform


def filter_response():
    InstanceDetails = {}
    InstanceList = []

    closed_account_list = filters('ignor_accounts.txt')
    ignor_instance_types = filters('ignor_instance_types.txt')
    ignor_platformss = filters('ignor_platforms.txt')


    if service == 'EC2':
        reccomeded_ri  = purchase_recom.ec2_reccomeded_ri('LINKED')
        Eng = 'Platform'
        details = 'EC2InstanceDetails'

    elif service == 'RDS':
        reccomeded_ri  = purchase_recom.rds_reccomeded_ri('LINKED')
        Eng = 'DatabaseEngine'
        details = 'RDSInstanceDetails'

    else: 
        print("Hit by a bludger")  #does not work
        exit
        
    
    data = json.dumps(reccomeded_ri)
    dictonary = json.loads(data)
    #Cleans out reccomendations for accounts and versions we dont care about
    for item in dictonary['Recommendations']:
        
        for result in item['RecommendationDetails']:
            InstanceDetails = {}

            AccountId =  result['AccountId']
            InstanceType  = result['InstanceDetails'][details]['InstanceType']
            Recommendation_number = result['RecommendedNumberOfInstancesToPurchase']
            Region  = result['InstanceDetails'][details]['Region']

            Platform  = result['InstanceDetails'][details][Eng]

            if AccountId in closed_account_list:
                pass
            elif InstanceType in ignor_instance_types:
                pass
            elif Platform in ignor_platformss:
                pass
            elif Region != 'EU (Ireland)':
                pass
            else:
                InstanceDetails.update(result['InstanceDetails'][details])
                InstanceDetails["RecommendedNumberOfInstancesToPurchase"] = Recommendation_number
    
                InstanceList.append(InstanceDetails)

    return (InstanceList)


def combine_reccomendation(service):
    reccomendation = []
    instance_details= filter_response()
    instance_type = Instance_Type(instance_details)
    if service == 'EC2':
        Eng = 'Platform'
    elif service == 'RDS':
        Eng = 'DatabaseEngine'

    platforms = Platform(Eng, instance_details)

    #used platform as a base to combine results
    for os in platforms:
 
        for in_type in instance_type:
            counter =0
            for rec in instance_details:
                if rec[Eng] == os and rec['InstanceType'] == in_type:
                    counter += int(rec['RecommendedNumberOfInstancesToPurchase'])
            #this is for cases were types are for one platform not the other
            if counter != 0:
                reccomendation.append({
                    "Instance_Type" : in_type,
                    "Eng" : os,
                    "Number" : counter
                })
    return reccomendation
                

def lambda_handler(event, context):
    service = os.environ["SERVICE"]
    reccomendation = combine_reccomendation(service)
    reccomeded_ri  = purchase_recom.risk(reccomendation, service)



