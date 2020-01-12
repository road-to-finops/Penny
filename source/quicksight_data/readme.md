#Quicksight data source & data set for athena 

This script will setup a data source and from that a set from an athena database in eu-west-1

As this is confiured for penny for a single use lambda it has ENV variables setup but it is possible to run locally calling the function by adding this at the base of the code

'''
lambda_handler(None, None)
'''



There are still some varibles that will need to be exported 
export examples:
   export ACCOUNT_ID="<account_id>"
   export DATA_SOURCE_ID="<Name for the data source>"
   export DATA_SET_ID="<Name for the data set>"
   export ATHENA_DATABASE="<Name of athena DB>"
   export ATHENA_TABLE="<Name of athena Table>"
   export  USER_ARN="<arn of a user you wish to be able to see this data>"


Then running 

>> python main.py