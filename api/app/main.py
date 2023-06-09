#Python main script to procces GIS data and obtain 
# several bike-path-oriented metrics of a given topology 

#TODO: create connection, read the queries, analize parameters to use, 
# put paremeters in sql and create pipeline with exceptions.


import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv
import argparse
import sys
import utils

parser = argparse.ArgumentParser(description='Run necessary queries to create the tables with results in postgreSQL')
parser.add_argument("--inhibir", dest="inhibir", required=True, type=int, help="inhibir o no la red")
parser.add_argument("--inhibir", dest="inhibir", required=True, type=int, help="inhibir o no la red")


#load env variables
load_dotenv()

#define variables of
DATABASE_NAME = os.getenv('URL_ENGINE')
HOST = os.getenv('HOST')
PORT = os.getenv('PORT')
USER = os.getenv('USER')
PASSWORD = os.getenv('PASSWORD')



def data_pipeline(file_path, table_name, queries):
    '''
    - Description: Execute the functions in order to get the result 
    - Input: path of csv file, tabla name in postgres of the result, 
    list of queries (str).
    '''
    # Read CSV to DataFrame
    df = utils.read_csv_to_df(file_path)

    # Connect to PostgreSQL
    conn = utils.create_conn(DATABASE_NAME,HOST,PORT,USER,PASSWORD)

    # Insert DataFrame into PostgreSQL
    utils.df_to_postgres(df, table_name)

    # Execute SQL queries
    for query in queries:
        utils.execute_query_with_params(conn, query)


def main():
    sys.setrecursionlimit(1500)
    args = parser.parse_args()
    data_pipeline(args.inhibir, args.inhibir)

if __name__=='__main__':
    main()
    #python3 main.py --inhibir=0 --inhibir=1 





# Example usage
#data_pipeline('my_data.csv', 'my_table', ['SQL QUERY 1', 'SQL QUERY 2'])