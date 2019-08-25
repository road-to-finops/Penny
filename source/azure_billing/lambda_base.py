import csv
import logging
from io import StringIO

log = logging.getLogger()


def order_headings(additional_headings, headings):
    log.info(f"Sorting Headings order with {headings} as initial")

    for heading in additional_headings:
        if heading not in headings:
            headings.append(heading)

    return headings


def get_all_headings(data):
    keys = [i.keys() for i in data]
    return {y for x in keys for y in x}


def generate_csv(data, headings=[]):
    log.info(f"Generating CSV")

    f = StringIO()
    if isinstance(data[0], dict):
        all_headings = get_all_headings(data)
        ordered_headings = order_headings(all_headings, headings)
        writer = csv.DictWriter(f, fieldnames=ordered_headings)
        writer.writeheader()
    elif isinstance(data[0], list):
        writer = csv.writer(f)

    for row in data:
        writer.writerow(row)

    return f.getvalue()



import logging
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import boto3
from botocore.exceptions import ClientError

log = logging.getLogger()


def build_email(subject, to_email, from_email, body=None, attachments={}):
    msg = MIMEMultipart("mixed")
    msg["Subject"] = subject
    msg["To"] = ",".join(to_email) if isinstance(to_email, list) else to_email
    msg["From"] = from_email

    if body and isinstance(body, dict):
        textual_message = MIMEMultipart("alternative")
        for m_type, message in body.items():
            part = MIMEText(message, m_type)
            textual_message.attach(part)
        msg.attach(textual_message)
    elif body and isinstance(body, str):
        msg.attach(MIMEText(body))

    if attachments:
        for filename, data in attachments.items():
            att = MIMEApplication(data)
            att.add_header("Content-Disposition", "attachment", filename=filename)
            msg.attach(att)

    return msg


def send_email(msg, region, session=boto3):
    ses = session.client("ses", region_name=region)
    try:
        response = ses.send_raw_email(
            Source=msg["From"],
            Destinations=msg["To"].split(","),
            RawMessage={"Data": msg.as_string()},
        )
    except ClientError as e:
        log.error(e.response["Error"]["Message"])
    else:
        id = response["MessageId"]
        log.info(f"Email sent! Message ID: {id}")



def assume_role(role_arn, role_session_name):
    log.info(f"Trying to Assume Role with arn: {role_arn}")
    try:
        sts_client = boto3.client("sts")
        assumed_role_object = sts_client.assume_role(
            RoleArn=role_arn, RoleSessionName=role_session_name
        )
        creds = assumed_role_object["Credentials"]
        boto_session = boto3.session.Session(
            creds["AccessKeyId"], creds["SecretAccessKey"], creds["SessionToken"]
        )

        return boto_session
    except ClientError as e:
        if e.response["Error"]["Code"] == "AccessDenied":
            log.error(f"Unable to Assume Role with arn: {role_arn}")
        raise

def format_arn(  # noqa: E302
    partition="aws", service="", region="", account_id="", resource_type="", resource=""
):
    return f"arn:{partition}:{service}:{region}:{account_id}:{resource_type}/{resource}"


def format_athena_partition(file_name, prefix="", partitions={}, file_ext="json"):
    """
    Args:
        file_name (str): name of file
        prefix (str): Used to prefix partition output
        partitions (dict): construct k=v/ pairs in order of dictionary
        file_ext (str): name of file_extension, default=json
    Returns:
        prefix/k=v/file_name.file_ext (
            k=v is repeated for each k/v pair in partitions
        )
    """

    partition = "".join([f"{k}={v}/" for k, v in partitions.items()])

    partition = f"{partition}{file_name}.{file_ext}"
    if prefix:
        return f"{prefix}/{partition}"
    else:
        return partition


import logging
import sys
import warnings

logger = logging.getLogger()
for h in logger.handlers:
    logger.removeHandler(h)
h = logging.StreamHandler(sys.stdout)
# use whatever format you want here
FORMAT = "%(asctime)-15s [%(filename)s:%(lineno)d] :%(levelname)8s: %(message)s"
h.setFormatter(logging.Formatter(FORMAT))
logger.addHandler(h)
logger.setLevel(logging.INFO)
# Suppress the more verbose modules
logging.getLogger("__main__").setLevel(logging.DEBUG)
logging.getLogger("botocore").setLevel(logging.WARN)
logging.getLogger("pynamodb").setLevel(logging.INFO)
warnings.filterwarnings(action="ignore", category=UserWarning, module="fuzzywuzzy")