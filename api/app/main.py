# este el archivo de la api, donde estaran los endpoints

#importing libraries
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from .models import Cities, Stations, GasPrices
from .services import engine, create_db_and_tables
# to load env variables


#We create an instance of FastAPI
app = FastAPI()



#We define authorizations for middleware components
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#We use a callback to trigger the creation of the table if they don't exist yet
#When the API is starting
@app.on_event("startup")
def on_startup():
    create_db_and_tables()


@app.get("/")
async def read_root():
    path = os.getcwd()
    return {"Hello": "nacho"}, 