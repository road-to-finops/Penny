Compute Optimizer Summary

Gathers Optimiser Rec for EC2 for estate useing Recharger into json file 

```
>> aws-vault exec <root>
>> python3 -m venv .venv
>> . .venv/bin/activate
>> pip3 install -r requirements.txt 
>> export TOKEN=<rechargertoken>
>> export API_URL=https://recharger.customappsteam.co.uk
>> export BUCKET_NAME=kpmgcloud-cost-report
>> python3 main.py
```