# Autor: Ignacio Hernández C.
# E-mail: ignacio.hernandez.c@usach.cl
# Fecha: septiembre, 2022
# 
# Descripcion: Este archivo contiene la ejecución de la unión de la red ciclo
# con la red OSM.
#
# Indice -----------------------------------------------------------------------
# 0. Importacion de librerias y funciones.
# 1. Prueba de conexión con la base de datos.
# 2.1 Leer, y cargar la base de ciclovias y calles a POSTGRESQL
#2.1.1 Leer los archivos shp
#2.1.2 Cargar archivos a la base POSTGRESQL
# 2.2 Union de ambas bases
# 3. Importar capa a PostGIS

# 0. Importacion de librerias y funciones -------------------------------------
packages <- c("here","dplyr","sf","igraph","lwgeom","data.table","RPostgreSQL")
install.packages(setdiff(packages,rownames(installed.packages())))
library(here)        # Gestionar rutas relativas
library(dplyr)       # Trabajar con dataframes
library(DBI)
library(RPostgreSQL)
library(sf)
library(data.table)

# -----------------------------------------------------------------------------
# ruta de carpeta en donde se localiza el archivo "create_intermodal_network.R"
# por ejemplo, en este caso el archivo estria en:
#   home/ruta/del/archivo/create_intermodal_network.R
# y la ruta de la carpeta seria:
#   home:/ruta/del/archivo/
setwd('~/grafos-accesibilidad/')
# -----------------------------------------------------------------------------

source(file = here("src/graph_helpers.r"))
source(file = here("src/sql_helper.r"))
source(file = here("config.r"))
#Algoritmo y ejecucion --------------------------------------------------------

#1. Prueba de conexión con la base de datos 
connec = test_database_connection(dsn_database,dsn_hostname,dsn_port,dsn_uid,dsn_pwd)

#2. Union de ambas bases
full_net=sf::st_as_sf(data.table::rbindlist(list(st_read(dsn,CICLO_BD_NAME),st_read(dsn,OSM_BD_NAME)),fill = TRUE))
full_net$NET_ID = c(1:nrow(full_net))
print(paste("Faltan las columnas: ",compulsory_fields[!(compulsory_fields %in% colnames(full_net))]))

#3. Importar capa a PostGIS
if (import_shape_to_database(shp = full_net, db = NETWORK_BD_NAME, connec = connec) != TRUE) {
  print("No fue posible cargar la red completa")
}
