import csv
import logging
from io import StringIO
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import boto3
from botocore.exceptions import ClientError

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