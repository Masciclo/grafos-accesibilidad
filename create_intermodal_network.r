# Autor: Ignacio Hernández C.
# E-mail: ignacio.hernandez.c@usach.cl
# Fecha: septiembre, 2022
# 
# Descripcion: Este archivo contiene el flujo de ejecucion para implementar el
# algoritmo de analisis de indicadores y metricas de red sobre redes de
# ciclovias.
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
packages <- c("here","dplyr","sf","igraph","lwgeom","data.table")
install.packages(setdiff(packages,rownames(installed.packages())))
library(here)        # Gestionar rutas relativas
library(dplyr)       # Trabajar con dataframes
library(sf)          # Trabajar con simple features
library(igraph)      # Construir grafos
library(lwgeom)      # Para utilizar la funcion st_split()
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

source(file = here("src/graph_helpers.R"))
source(file = here("src/sql_helper.R"))
source(file = here("config.R"))
#Algoritmo y ejecucion --------------------------------------------------------

#1. Prueba de conexión con la base de datos 
connec = test_database_conection(dsn_database,dsn_hostname,dsn_port,dsn_uid,dsn_pwd)

#2. Union de ambas bases
full_net=sf::st_as_sf(data.table::rbindlist(list(st_read(dsn,CICLO_BD_NAME),st_read(dsn,OSM_BD_NAME)),fill = TRUE))

#3. Importar capa a PostGIS
if (import_shape_to_database(shp = full_net, db = NETWORK_SHP, connec = connec) != TRUE) {
  print("No fue posible cargar la red completa")
}
