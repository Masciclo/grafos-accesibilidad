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
# 1.1 Leer, y cargar la base de ciclovias y calles a POSTGRESQL
# 1.2 Crear y limpiar la topología de ambas bases

# 2. Preproceso y limpieza de geometrías.
# 3. Conversión de tipo de dato sf a tipo de dato igraph (tidygraph).

# 0. Importacion de librerias y funciones -------------------------------------
packages <- c("here","dplyr","sf","igraph","lwgeom","data.table","RPostgreSQL","DBI")
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
library(Dict)


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

#2.1 Leer y cargar inhibidores y desinhibidores

#2.1.1 Leer archivos shp
#Inhibidores
lista_inhibidores = dict(RED_BUSES_NAME = st_read(RED_BUSES_PATH, options = "ENCODING=latin1"),
                         RED_PRINCIPALES_NAME = st_read(RED_PRINCIPALES_PATH))

#Desinhibidores
lista_desinhibidores = dict(SEMAFOROS_NAME = st_read(SEMAFOROS_PATH))


#2.1.2 Importar archivos a la base PostgreSQL

#Inhibidores
for (inhibidor in lista_inhibidores$keys){
  print(paste("Cargando archivo ", inhibidor))
  if (import_shape_to_database(shp = lista_inhibidores[inhibidor], db = inhibidor, connec = connec) != TRUE) {
    print(paste("No fue posible cargar ",inhibidor))
  }
}

#Desinhibidores
for (desinhibidor in lista_desinhibidores$keys) {
  print(paste("Cargando archivo ", desinhibidor))
  if (import_shape_to_database(shp = lista_desinhibidores[desinhibidor], db = desinhibidor, connec = connec) != TRUE) {
    print(paste("No fue posible cargar ",desinhibidor))
  }
}

# 3. Cortar la red
network = cut_intermodal_network(nombre_resultado = 'esc7',
                                 red = NETWORK_BD,
                                 lista_inh = c(RED_BUSES_NAME,RED_PRINCIPALES_NAME),
                                 buffer_inh = 10,
                                 lista_des = c(SEMAFOROS_NAME),
                                 buffer_des = 25,
                                 )
