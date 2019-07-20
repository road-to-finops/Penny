import boto3
from botocore.exceptions import ClientError


def ec2_reccomeded_ri(AccountScope):
    #Gets reccomndations from AWS console for all linked accounts
    #AccountScope PAYER or LINKED
    client = boto3.client('ce')
    try:
        response = client.get_reservation_purchase_recommendation(
            Service= 'Amazon Elastic Compute Cloud - Compute',
            AccountScope= AccountScope, 
            LookbackPeriodInDays='THIRTY_DAYS',
            TermInYears='ONE_YEAR',
            PaymentOption='NO_UPFRONT',
            ServiceSpecification={
                'EC2Specification': {
                    'OfferingClass': 'STANDARD'
                }
            }
        )    
        return response
    except ClientError as e:
        print("Unexpected error: %s" % e)
        return none


def rds_reccomeded_ri(AccountScope):
    #Gets reccomndations from AWS console for all linked accounts
    #AccountScope PAYER or LINKED
    client = boto3.client('ce')
    try:
        response = client.get_reservation_purchase_recommendation(
            Service= 'Amazon Relational Database Service',
            AccountScope= AccountScope, 
            LookbackPeriodInDays='THIRTY_DAYS',
            TermInYears='ONE_YEAR',
            PaymentOption='NO_UPFRONT'
        )    
        return response
    except ClientError as e:
        print("Unexpected error: %s" % e)
        return none



def risk(data, service):
    if service == "EC2":
        overall_ri = ec2_reccomeded_ri('PAYER')
        Eng = 'Platform'
        details = 'EC2InstanceDetails'
    elif service == "RDS":
        overall_ri = rds_reccomeded_ri('PAYER')
        Eng = 'DatabaseEngine'
        details = 'RDSInstanceDetails'
    
    #instance = [instance['Instance_Type']for instance in data ]
    for instance in data:
        chosenInstanceType = instance['Instance_Type']
        chosenPlatform =  instance['Eng']

        for item in overall_ri['Recommendations']:
            
            for result in item['RecommendationDetails']:
                InstanceType  = result['InstanceDetails'][details]['InstanceType']
                Recommendation_number = result['RecommendedNumberOfInstancesToPurchase']
                Region  = result['InstanceDetails'][details]['Region']
                Platform  = result['InstanceDetails'][details][Eng]
                
                if InstanceType == chosenInstanceType and Platform  == chosenPlatform and Region == 'EU (Ireland)':
                    max_instance = int(float(result['MaximumNumberOfInstancesUsedPerHour']))
                    min_instance = int(float(result['MinimumNumberOfInstancesUsedPerHour']))
                    
                    if  (max_instance/2) <= min_instance:    
                        risk = ("Low Risk MaxInstance-%s MinInstance-%s" %(max_instance,min_instance))

                    else:
                        risk =("High Risk MaxInstance-%s MinInstance-%s" %(max_instance,min_instance))
            
                    instance['Risk'] = risk
                    print(instance)
                    
            
if __name__ == "__main__":

    print(rds_reccomeded_ri('LINKED'))


'''


############### see if can combine 
def filter_stuff():
        
        for result in item['RecommendationDetails']:
            InstanceDetails = {}

            AccountId =  result['AccountId']
            InstanceType  = result['InstanceDetails'][details]['InstanceType']
            Recommendation_number = result['RecommendedNumberOfInstancesToPurchase']
            Region  = result['InstanceDetails'][details]['Region']

            Platform  = result['InstanceDetails'][details][Eng]

'''