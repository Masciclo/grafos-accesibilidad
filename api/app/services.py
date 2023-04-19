# aca iran los servicios asi como tambien la conexion a la base de datos


#example:

from sqlmodel import SQLModel, create_engine
import models

DATABASE_URL = 'postgresql://jkaub:jkaub@localhost/stations'

engine = create_engine(DATABASE_URL)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)