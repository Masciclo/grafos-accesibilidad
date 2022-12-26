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


#2. Cortar la red

for (setting in settings_list) {
  cut_intermodal_network(
    nombre_resultado = setting$nombre_resultado,
    red = setting$red,
    filters = setting$filters,
    lista_inh = setting$lista_inh,
    buffer_inh = setting$buffer_inh,
    lista_des = setting$lista_des,
    buffer_des = setting$buffer_des,
    conn = connec
  )
}
