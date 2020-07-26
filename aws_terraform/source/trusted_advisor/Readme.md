# Elatic IP Realse
Find any unassociated EIPs and gives the option to release them

## Getting Started

These instructions will get you a copy of the Tool up and running on your local machine.

### Prerequisites

* Install Boto3
* Python3
* aws-vault

Ref: https://boto3.readthedocs.io/en/latest/guide/quickstart.html


### Running the Tool

Clone the Tool and run as below

```
aws-vault exec <cred>
./multi_account.py -m <methods> -m <region>

#### Methods
- stopped_ec2 - Stopped EC2
- cloudtrail - Extra cloud trails not org, audit or root (too change)
- eip - Unassigned eip
- elb - empty elb
- alb -empty alb
- ebs - unattahced EBS Volumes
- snapshot - snapshots older than 30 days
```
A Prompt will ask you if you wish to realse the ip use yes and no


#### Region
this is optional for all but TA.
It will use your deafult from your account if not specified

**********************

>>aws-vault exec <role>
>>python3 -m venv .venv
>>. .venv/bin/activate
>>pip3 install -r requirements.txt 
>> export RECHARGER_TOKEN=<token>
>>./main.py 