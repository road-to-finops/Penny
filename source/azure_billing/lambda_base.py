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
