# Base image
FROM postgis/postgis:latest

# Environment variables
ENV POSTGRES_USER 'postgres'
ENV POSTGRES_PASSWORD 'admin'
ENV POSTGRES_DB 'initial_db' 

# Copy initialization script
COPY ./sql-scripts/ /docker-entrypoint-initdb.d/

# Expose default PostgreSQL port
EXPOSE 5432