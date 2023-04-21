#It instructs Docker Engine to 
#use official python:3.9 as the base image
FROM python:3.9

#It creates a working directory(app/main) 
#for the Docker image and container
WORKDIR /app/main

#It copies the framework and the dependencies 
#for the FastAPI application into the working directory
COPY ./requirements.txt ./

#It will copy the remaining files and the source code from the 
#host api folder to the `api` container working directory
COPY . .

#It will install the framework and the dependencies 
#in the `requirements.txt` file.
RUN pip install --no-cache-dir -r requirements.txt


ENV PYTHONPATH /app

#It will expose the FastAPI application on port `8000` 
#inside the container
EXPOSE 8000

#configurar
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]