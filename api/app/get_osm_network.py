import os
import requests
import json
from google.cloud import storage

def download_road_network(city_name):
    overpass_api_url = "http://overpass-api.de/api/interpreter"
    query = f"""
[out:json];
area[name="{city_name}"]->.a;
(
  way(area.a)[highway];
  >;
);
out;
"""
    response = requests.get(overpass_api_url, params={'data': query})
    if response.status_code != 200:
        raise Exception(f"Error fetching data from Overpass API: {response.text}")
    return response.json()

def upload_to_gcs(data, bucket_name, file_name):
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(file_name)
    blob.upload_from_string(json.dumps(data), content_type="application/json")

if __name__ == "__main__":
    city_name = "some_city"
    gcs_bucket = "your_gcs_bucket_name"

    # Ensure your GOOGLE_APPLICATION_CREDENTIALS environment variable is set
    # with the path to your GCP service account key file.
    assert "GOOGLE_APPLICATION_CREDENTIALS" in os.environ, "Set GOOGLE_APPLICATION_CREDENTIALS env variable."

    road_network_data = download_road_network(city_name)
    upload_to_gcs(road_network_data, gcs_bucket, f"{city_name}_road_network_data.json")

    print(f"Road network data for '{city_name}' uploaded to GCS bucket '{gcs_bucket}'.")