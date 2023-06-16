import os
import psycopg2
import geopandas as gpd
from sqlalchemy import create_engine
from geoalchemy2 import Geometry
from shapely import wkt
import shapely.geometry.base

def create_conn(database_name, host, port, user, password):
    '''
    Description: This function creates a connection to a postgres database
    Input: database_name, host, port, user, password
    Output: connection object
    '''
    conn = psycopg2.connect(
        dbname=database_name,
        host=host,
        port=port,       
        user=user,
        password=password
    )
    return conn

def read_csv_to_df(file_path):
    '''
    Description: This function reads a csv file into a GeoPandas DataFrame
    Input: path of csv file
    Output: DataFrame
    '''

    df = gpd.read_file(file_path) # Read file
    
    # Check if all geometries are valid before converting to WKT
    if not all(df['geometry'].apply(lambda x: isinstance(x, shapely.geometry.base.BaseGeometry))):
        raise ValueError("All values in the 'geometry' column are not valid geometries.")
        
    # Convert MultiLineString to WKT geometry
    df['geometry'] = df['geometry'].apply(lambda geom: wkt.dumps(geom))
    # Rename column 'geometry' to 'geom'
    return df

def df_to_postgres(df, table_name, user, password, host, port, database_name):
    '''
    Description: upload a df object into a database
    Input: df object (from read_csv_to_df function) and a name for the table   
    '''
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{database_name}')
    df.to_sql(table_name, 
              engine, 
              if_exists='replace', 
              index=False,
              dtype={'MULTILINESTRING': Geometry(geometry_type='MULTILINESTRING',
                                       srid=32719)})

def read_sql_file(file_path):
    '''
    Description: read an SQL file and create a string object with the query 
    Input: path of SQL file
    Output: SQL query as a string
    '''
    with open(file_path, 'r') as file:
        sql = file.read()
    return sql

def execute_query_with_params(conn, query, params):
    '''
    Description: Executes a query on a connection with given parameters
    Input: conn - connection object, query - SQL query string, params - tuple of parameters
    '''
    with conn.cursor() as cursor:
        cursor.execute(query, params)
        conn.commit()