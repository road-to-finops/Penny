import os
import json
import datetime
from google.cloud import storage
from google.cloud import bigquery_storage_v1beta1


def bq_extraction(**kwargs):
    client = bigquery_storage_v1beta1.BigQueryStorageClient()

    # This example reads baby name data from the public datasets.
    table_ref = bigquery_storage_v1beta1.types.TableReference()
    table_ref.project_id = kwargs['project_id']
    table_ref.dataset_id = "billing"
    table_ref.table_id = "gcp_billing_export_v1_013897_8670C0_F99FFA"

    # We limit the output columns to a subset of those allowed in the table,
    # and set a simple filter to only report names from the state of
    # Washington (WA).
    read_options = bigquery_storage_v1beta1.types.TableReadOptions()
    read_options.row_restriction = 'usage_start_time = "{}"'.format(kwargs['start_date'])
    read_options.row_restriction = 'usage_end_time = "{}"'.format(kwargs['end_date'])

    # Set a snapshot time if it's been specified.
    modifiers = None
    snapshot_millis = 0
    if snapshot_millis > 0:
        modifiers = bigquery_storage_v1beta1.types.TableModifiers()
        modifiers.snapshot_time.FromMilliseconds(snapshot_millis)

    parent = f"projects/{(kwargs['project_id']}"
    session = client.create_read_session(
        table_ref,
        parent,
        table_modifiers=modifiers,
        read_options=read_options,
        # This API can also deliver data serialized in Apache Arrow format.
        # This example leverages Apache Avro.
        format_=bigquery_storage_v1beta1.enums.DataFormat.AVRO,
        # We use a LIQUID strategy in this example because we only read from a
        # single stream. Consider BALANCED if you're consuming multiple streams
        # concurrently and want more consistent stream sizes.
        sharding_strategy=(bigquery_storage_v1beta1.enums.ShardingStrategy.LIQUID),
    )  # API request.

    # We'll use only a single stream for reading data from the table. Because
    # of dynamic sharding, this will yield all the rows in the table. However,
    # if you wanted to fan out multiple readers you could do so by having a
    # reader process each individual stream.
    reader = client.read_rows(
        bigquery_storage_v1beta1.types.StreamPosition(stream=session.streams[0])
    )

    # The read stream contains blocks of Avro-encoded bytes. The rows() method
    # uses the fastavro library to parse these blocks as an interable of Python
    # dictionaries. Install fastavro with the following command:
    #
    # pip install google-cloud-bigquery-storage[fastavro]
    rows = reader.rows(session)

    # Temp structure for storing wole dataset read from BQ
    data = []

    for row in rows:
        for k, v in row.items():
            # Below if is to combat json.dumps inability to parse datetime
            # class
            if type(v) is datetime.datetime:
                row[k] = v.strftime("%Y-%m-%dT%H:%M:%S")
        data.append(row)

    return json.dumps(data)


def gcs_upload(json, bname, date):
    path = f"{date.year}/{date.month}"
    oname = f"kpmg-{date.year}-{date.month}-{date.day}.json"

    client = storage.Client()
    bucket = client.get_bucket(bname)
    blob = bucket.blob(f'{path}/{oname}')
    blob.upload_from_string(json)

    return blob.public_url


def main(req):
    # The read session is created in this project. This project can be
    # different from that which contains the table.
    PROJECT_ID = os.environ.get('PROJECT_ID', 'billing-data-193675')
    GCS_BUCKET = os.environ.get('GCS_BUCKET', 'billing_data-193675')
    now = datetime.datetime.today()
    yday = now - datetime.timedelta(days=1)
    today = now.strftime("%Y-%m-%d")
    yesterday = yday.strftime("%Y-%m-%d")

    data = bq_extraction(project_id=PROJECT_ID,
                         start_date=f'{yesterday} 00:00:00+00:00'
                         end_date=f'{today} 00:00:00+00:00'

    gcs_upload(data, GCS_BUCKET, yday)

if __name__ == '__main__':
    main()
