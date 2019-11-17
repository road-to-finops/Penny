# Penny
This is a tool to help with AWS billing and reporting.

The goal for this deployment is to start collecting your Cost and Uage report from AWS in a format for athena to read. 


This stems from the AWS supplied cloud formation but running this script means there is no manual procces

CUR proccess:

- A terraform to create s3 for billing to go into
- Athana database 
- Glue crawler to keep tabel uptodat


## Steps

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
It will need with programtic access with the administrator policy. See AWS instructions here
[Creating Your First IAM Admin User and Group - AWS Identity and Access Management](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)

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
Replace the account number with your account number
```
aws s3api create-bucket --bucket penny-bucket-*accountnumber*- -region eu-west-1 --profile penny
```

6. Update the Terraform files

Open 'backend.tf' and replace the account number with your account number
 
7. Deploy Terraform
```
terraform init
terraform plan
terraform apply
```

#### Notes
Terraform v0.11.13
Python 3.6.5 
Windows install 
