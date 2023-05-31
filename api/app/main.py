import os
from google.cloud import storage
import pandas as pd
from sqlalchemy import create_engine, text
from geoalchemy2 import Geometry, WKTElement
from shapely.geometry import Point
# work with env variables
from dotenv import load_dotenv

#loas env variables
load_dotenv()

#define variables of GCP and SQL.
URL_ENGINE = os.getenv('URL_ENGINE')
BUCKET_NAME = os.getenv('BUCKET_NAME')

# Create storage client
storage_client = storage.Client()

def process_csv(data, context):
    """Background Cloud Function to be triggered by Cloud Storage.
       This function gets executed when a file is uploaded to Google Cloud Storage"""
    bucket_name = data[BUCKET_NAME]
    file_name = data['name']
    blob = storage_client.get_bucket(bucket_name).blob(file_name)

    # Download the contents of the blob as a string
    data = blob.download_as_text()
    
    # Read the CSV data using pandas
    df = pd.read_csv(data)
    
    # Convert latitude and longitude to a Point object
    df['geom'] = df.apply(lambda row: WKTElement(Point(row['longitude'], row['latitude']).wkt, srid=4326), axis=1)
    
    # Drop latitude and longitude as it's no longer required
    df = df.drop(['longitude', 'latitude'], axis=1)
    
    # Create SQLAlchemy engine
    engine = create_engine('postgresql://user:password@localhost/your-database-name')

    # Write DataFrame to PostgreSQL
    df.to_sql('your-table-name', engine, if_exists='append', index=False, dtype={'geom': Geometry('POINT', srid=4326)})
    
    # Execute your PostGIS and pgRouting SQL queries
    with engine.connect() as connection:
        result = connection.execute(text("""
            -- Your SQL query goes here
        """))
    
    # Write results back to GCS as a CSV
    results_df = pd.DataFrame(result.fetchall())
    results_df.to_csv('gs://your-bucket-name/results.csv')
