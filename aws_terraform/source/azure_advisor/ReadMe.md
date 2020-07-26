To Run:
Edit the tennat id in script

>> export ARM_CLIENT_SECRET=""
>> export ARM_CLIENT_ID=""

With Virtual Env wrapper run:
>> workon <azure>

Install requirments:
>> pip install -r requirements.txt

Run:
>> python advisor.py > file.csv


Requirments:
- User with Reader persmissions per subscription -> IAM -> role assignement ->add as reader
- They secret key and id of the user
- Virtualenv
- python