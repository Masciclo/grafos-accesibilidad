import os
import psycopg2

#create connection
def create_conn(database_name,host,port,user,password ):
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
    Description: This function read some csv in the localhost
    Input: path of csv file
    '''
    df = gpd.read_file(file_path)
    return df


def df_to_postgres(df, table_name):
    '''
    Description: upload a df object into a database
    Input: df object (from read_csv_to_df function) and a name for the table   
    '''
    engine = create_engine(f'postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE_NAME}')
    df.to_sql(table_name, engine, if_exists='replace', index=False)


def read_sql_file(file_path):
    '''
    Description: read a sql file and create a string object with the query 
    Input: path of sql file
    '''
    with open(file_path, 'r') as file:
        sql = file.read()
    return sql

def read_sql_file(file_path):
    '''
    Description: read an SQL file and create a string object with the query 
    Input: path of SQL file
    '''
    with open(file_path, 'r') as file:
        sql = file.read()
    return sql

def execute_query_with_params(conn, query, params):
    with conn.cursor() as cursor:
        cursor.execute(query, params)
        conn.commit()

