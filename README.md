# Penny
This is a tool to help with AWS billing and reporting.

The goal for this deployment is to start collecting your Cost and Uage report from AWS in a format for Athena to read. 


This stems from the AWS supplied cloud formation but running this script means there is no manual procces

CUR proccess:

- A terraform to create s3 for billing to go into
- Athana database 
- Glue crawler to keep tabel up-to-date


## Steps

### Pre-requisites

1. Make sure you're running the right version of Terraform locally - see the Notes section below.
You can use 'asdf' to manage differt versions of Terraform. See here for more information:
https://wiki.customappsteam.co.uk/display/COF/New+Joiner+MAC

2. Make sure you're running the right version of Python locally - See the Notes section below.
Again you can use 'asdf' to control this.

3. Make sure that your AWS default region is set correctly.
The region specified in your penny profile should match that in your local $AWS_DEFAULT_REGION environment variable.

4. Make sure the IAM policy you're using covers access to all the AWS services that you're using.
If you've coded up some Terraform for a new AWS service then the policy will need to change.
See "iam.json" for the policy definition.


### Set up 

1. Clone this repo to a location on your laptop

``` 
git clone https://github.com/road-to-finops/Penny.git
```

2. Install terraform 
[Terraform – Getting Started – Install Terraform on Windows, Linux and Mac OS | Vasos Koupparis](https://www.vasos-koupparis.com/terraform-getting-started-install/)

``` 
brew install terraform
```

4. Install AWS cli

[Installing the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

```
pip3 install awscli --upgrade --user
```



3. Create an AWS IAM User
This needs to be in your **billing account**.  It will need with programtic access with the administrator policy. See AWS instructions here
[Creating Your First IAM Admin User and Group - AWS Identity and Access Management](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)

Create using the policy in the iam.json file

Copy the Access and Secret key to your machine

4. Setup your aws profile
```
$ aws configure --profile penny
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: eu-west-1
Default output format [None]: json
```

5. Create s3
Replace the account number with your billing account number
```
aws s3api create-bucket --bucket penny-bucket-*account-number* --region eu-west-1 --profile penny  --create-bucket-configuration LocationConstraint=eu-west-1
```

6. Update the Terraform files
Go to the AWS Terraform folder
Open 'backend.tf' and replace the account number with your account number.
Open 'varibles.tf' and add to account id 
 

7.  Create SSM
We are uisng SSM param stores for the below keys. You can add these to run code or if your not uing gcp/azure you can delet lambdas and SSM. Or if you have your own password stores add them to the lambdas. See ssm.tf for connection
aws ssm put-parameter --name "/penny/azure/azure_api"  --value "azure_api"  --type String --profile penny
aws ssm put-parameter --name "/penny/azure/azure_enrolmentid"  --value "azure_enrolmentid"  --type String --profile penny
aws ssm put-parameter --name "/penny/big_query/big_query_api"  --value "big_query_api"  --type String --profile penny


8. Deploy Terraform
```
terraform init
terraform plan
terraform apply
```
9. Run setup lambda
```
aws lambda invoke --function-name lambda_cur out --log-type Tail --profile penny
```


Now you have setup your access, deployed your terraform and triggered your lambda function you are all setup.

The first Cost and Usage report takes 24hr to appear in your s3 bucket so set your timer and look out for your athena tabel.

Once the 24hrs is comeplete you should have an Athena Database with your aws billing data in it.

## Next Steps

### Reports
To run more exciting data collection or better yet reports for your data you can use the avalible terraform. Using these documents you can setup billing for your accounts.

See the wiki for details 
[Home · road-to-finops/Penny Wiki · GitHub](https://github.com/road-to-finops/Penny/wiki)

### Visualization 

After you have data in the anthea table you can put it in AWS Quicksight
https://aws.amazon.com/blogs/big-data/query-and-visualize-aws-cost-and-usage-data-using-amazon-athena-and-amazon-quicksight/
By running the quicksight lambda and passing in a relevent user ARN you will have a data setup for aws billing data

#### Notes
- Terraform v0.11.13
- Python 3.6.5 
 
#### BONUS

GCP:
To create a GCP tabel 

aws athena  create-named-query --name gcp_billing --database  --query-string file/gcp.sql
