import functions_framework
from flask import Response
from google.cloud import storage
from datetime import datetime
import os

def loader(file):
    # Get bucket
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(os.environ.get('BUCKET_NAME'))

    # Save received file as temp
    temp_filename = 'tempdata.csv'
    file.save(temp_filename)

    # Create blob using temp's file content
    blob = bucket.blob(f'crypto_marketcap-{str(datetime.now())}')
    blob.upload_from_filename(temp_filename)

    # Remove temp file
    os.remove(temp_filename)

    return Response(None, 201)


@functions_framework.http
def load_file_into_cloud_storage(request):
    """
      Receives a file and loads it into GCP Cloud Storage
    """

    if (request.method == 'POST' and len(request.files) == 1):
        return loader(request.files['file'])

    return Response(None, 405)
