import os
from dotenv import load_dotenv
from sqlmodel import SQLModel, create_engine
#import models 

#loas env variables
load_dotenv()

# Variables
DATABASE_NAME = os.getenv('DATABASE_NAME')
HOST = os.getenv('HOST')
PORT = os.getenv('PORT')
USER = os.getenv('USER')
PASSWORD = os.getenv('PASSWORD')

#build database url
DATABASE_URL = 'postgresql://postgres:admin@postgres:5432/masciclo_db'

engine = create_engine(DATABASE_URL)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)