# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2020-07-28
- Changes added a bit to TA fucntion to convert the code to lower case for crawlers and remove dollar signs 

## [1.2.0] - 2020-07-16
- Changes Upgraded to terraform 12
- Add SSM file and how to add them


## [1.0.13] - 2020-06-16
- Changes for FOPS-902 
- Add error if Athena Query returns no results to finops bill to athena_query_lambda.tf


## [1.0.12] - 2020-05-22
- Changes for FOPS-845 Update Azure in Penny
  Copy the following files from the Tech solutions Billing repo (Master branch)
    aws_terraform/Athena_Queries/azure_billing_export.sql
    aws_terraform/athena_tables/azure_marketplace.sql
    aws_terraform/athena_tables/azure_reserved.sql
    aws_terraform/athena_tables/azure_usage.sql
    aws_terraform/azure_billing_collector.tf
    aws_terraform/dates_collector_lambda.tf
    aws_terraform/event_bills.tf
    aws_terraform/source/azure_billing_collector/
    aws_terraform/source/dates_collector
    Adjusted some variables, resource names, referenced penny S3 bucket, and replaced vault with variables.
- Added an Azure SQS que to aws_terraform/sqs.tf
- Added azure_billing_report_cron to variables.tf

## [1.0.11] - 2020-05-19
- Changes for FOPS-862 Parameter Store for Penny
  Update big_query_lambda.tf to put the API environment variable from AWS Parameter Store.
  Note: Parameter value entered manually in the Console and has not been hard coded in the terraform code.
        Parameter value encrypted with the default AWS KMS key.
        Values are only read from and not written to Parameter Store.

## [1.0.10] - 2020-05-14
- Changes for FOPS-856 Add versioning to Penny S3 bucket
  Update s3.tf to enable versioning of the bucket.
  Note: Changes were also made to README.md to enable versioning on the terraform state bucket:
  aws s3api put-bucket-versioning --bucket penny-bucket-*account-number* --region eu-west-1 --profile penny --versioning-configuration Status=Enabled 

## [1.0.9] - 2020-05-14
- Changes for FOPS-832 Add SP to Penny
  Copy the files from the Tech Solutions Billing repo as per the ticket.
     athena_views/pricing.sql
     athena_views/sp_pricing.sql
     source/sptool_odpricing_download.py
     source/sptool_sppricing_download.py
     crawler.tf
     lambda.tf
     variables.tf
  Adjust variable names to Penny standards.

## [1.0.8] - 2020-04-27
- Changes for FOPS-844 Add BQ queries in Penny
  Copy the files from the Tech Solutions Billing repo as per the ticket.
    BigQuery_Queries/gcp_billing_bq.sql
    module/events/events.tf
    module/events/variables.tf
    source/athena_query_lambda/lambda.py
    source/big_query/example.tf
    source/big_query/lambda_base.py
    source/big_query/main.py
    source/big_query/requirements.txt
    athena_query_lambda.tf
    big_query_lambda.tf
    variables.tf
  Adjust variable names to Penny standards.

## [1.0.7] - 2020-04-27
- Changes for FOPS-728 Add Events Lambda to Penny
  Replace multiple lamba queries with the new approach documented here:
  https://wiki.customappsteam.co.uk/display/CEF/Athena+Query+Reports
  Lots of file changes see the PR for details.

## [1.0.6] - 2020-04-27
- Changes for FOPS-843 Update GCP to BQ
  Update the GCP lambda to pull project data from BigQuery billing in GCP


## [1.0.5] - 2020-03-24
- Changes for FOPS-623 Azure Update In Penny
  Copy the following files from the Tech solutions Billing repo (Master branch)
    aws_terraform/source/azure_billing/azure.py
    aws_terraform/source/azure_billing/requirements.txt
    No changes to variable or filenames was required.

## [1.0.4] - 2020-03-23
- Changes for FOPS-768 Fix GCP bug in Penny
  Copy the following files from the Tech solutions Billing repo (Dev branch) and adjust variable, database and bucket names.
    crawler.tf
    source/gcp_billing/gcp_billing.py
    source/gcp_billing/requirements.txt

## [1.0.3] - 2020-03-19
- Changes for FOPS-769 Add Trusted Advisor to Penny
  Copy the following files from the Tech solutions Billing repo (post FOPS-736) and adjust variable, database and trigger names:
    trusted_advisor.tf
    accounts_collector_lambda.tf
    crawler.tf
    sqs.tf
    source/trusted_advisor
    source/accounts_collector.py

- Changes for FOPS-771 Add Compute Optimiser to Penny
  Copy the following files from the Tech solutions Billing repo (post FOPS-736) and adjust variable, database and trigger names:
    compute_optimiser.tf
    crawler.tf
    sqs.tf
    source/compute_optimiser

- Change 'icm_billing_cron' to 'first_of_the_month_cron' in the following files:
    accounts_collector_lambda.tf
    compute_optimiser.tf
    trusted_advisor.tf
    varibles.tf

## [1.0.2] - 2020-03-12
- Updated README.md and CHANGELOG.md to reflect process refinements
- Update files/gcp_data from .csv to .json
- update .tool-versions for Terraform 0.11.14 and Python 3.6.7
- Add glue permissions to iam.json

## [1.0.1] - 2019-08-25
### Added
- GCP billing

## [1.0.0] - 2019-08-25
### Added
- Change log
- Azure billing
### Changed
- na
### Removed
- na
