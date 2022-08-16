# Autor: Matias Duran Niedbalski & Ignacio Hernández C.
# E-mail: matias.duran@usach.cl & ignacio.hernandez.c@usach.cl
# Fecha: agosto, 2022
# 
# Descripcion: Este archivo contiene el flujo de ejecucion para implementar el
# algoritmo de analisis de indicadores y metricas de red sobre redes de
# ciclovias.
#
# Indice -----------------------------------------------------------------------
# 0. Importacion de librerias y funciones.
# 1. Lectura de archivos de entrada (formato *.shp o *.geojson).
# 2. Preproceso y limpieza de geometrías (Ciclovías y OSM).
# 2.1. Split de ciclovías y OSM sobre si mismos.
# 2.2. Split de ciclovías y OSM entre ellos.
# 2.3. Unión.
# 3. Conversión de tipo de dato sf a tipo de dato igraph (tidygraph).
# 4. Aplicación de inhibidores y deshinibidores
# 5. Filtro de dataset según escenario.
# 6. Cálculo de indicadores
# 6.1. Se agrega un identificador de componente a cada arco.
# 6.2. Calcula indicadores para el caso general.
# 6.3. Calcula indicadores para cada subcomponente.
# 6.3.1. Casos operativos; gi_comp: id_c|largo_t|largo_prom|beta_index|diametro|
#                                   n_sub_comp
# 6.3.2. Casos inoperativos; gsub_inop_comp:  id_c_sub_inop|id_c|largo_t|
#                                             largo_prom|c_close|c_betwee|
#                                             c_straigth
# 6.3.3. Casos proyectados: gsub_pro_co:  id_c_sub_pro|id_c|largo_t|largo_prom|
#                                         c_close|c_betwee|c_straigth
# 6.4. Count the number of subcomponents for each component
# 7. Exportación de archivos en formato *.csv y *.geojson.
# 7.1. gi_comp: id_component|largo_t|largo_prom|beta_index|diametro|
#               c_betweenness|c_closeness|c_straightness|n_gsub_op_comp|
#               n_gsub_inop_comp|n_gsub_pro_com
# 7.2. gsub_op_comp:  id_component|largo_t|largo_prom|beta_index|diametro|
#                     c_betweenness|c_closeness|c_straightness
# 7.3. gsub_inop_comp:  id_component|largo_t|largo_prom|beta_index|diametro|
#                       c_betweenness|c_closeness|c_straightness
# 7.4. gsub_pro_com:  id_component|largo_t|largo_prom|beta_index|diametro|
#                     c_betweenness|c_closeness|c_straightness
# 7.5. gi_aristas (tabla CSV):  from|to|id_aris|id_2|id_c|weight|id_c_sub_op|
#                               eb_sub_op|ec_sub_op|es_sub_op|d_sub_op|
#                               id_c_sub_inop|eb_sub_inop|ec_sub_inop|
#                               es_sub_inop|d_sub_inop|id_c_sub_pro|
#                               eb_sub_pr|ec_sub_pr|es_sub_pr|d_sub_pr
# 7.6. gi_aristas (tabla GeoJSON):  from|to|id_aris|id_2|id_c|weight|id_c_sub_op|
#                                   eb_sub_op|ec_sub_op|es_sub_op|d_sub_op|
#                                   id_c_sub_inop|eb_sub_inop|ec_sub_inop|
#                                   es_sub_inop|d_sub_inop|id_c_sub_pro|
#                                   eb_sub_pr|ec_sub_pr|es_sub_pr|d_sub_pr
# 7.7. Exportacion de un archivo geojson por cada componente.

# 0. Importacion de librerias y funciones -------------------------------------
library(here)        # Gestionar rutas relativas
library(dplyr)       # Trabajar con dataframes
library(sf)          # Trabajar con simple features
library(igraph)      # Construir grafos
library(lwgeom)      # Para utilizar la funcion st_split()

# -----------------------------------------------------------------------------
# ruta de carpeta en donde se localiza el archivo "calculate_metrics.R"
# por ejemplo, en este caso el archivo estria en:
#   c:/ruta/del/archivo/calculate_metrics.R
# y la ruta de la carpeta seria:
#   c:/ruta/del/archivo/
setwd('D:/+CICLO/repos/planarize/mas-ciclo/shp_graph_metrics')
# -----------------------------------------------------------------------------

source(file = here('src/graph_helpers.R'))
source(file = here('src/h3_helpers.R'))
source(file = here('config.R'))

# Algoritmo y ejecucion --------------------------------------------------------
# 1. Lectura de archivos de entrada (formato *.shp o *.geojson). ---------------
# bicycle_network_gdf = join_polylines(sf::st_read(CICLO_SHP_PATH), sf::st_read(OSM_SHP_PATH))
bicycle_network_gdf = sf::st_read(CICLO_SHP_PATH)
bicycle_network_gdf = bicycle_network_gdf[!sf::st_is_empty(bicycle_network_gdf$geometry),]
names(bicycle_network_gdf) = tolower(names(bicycle_network_gdf))

# Validar columnas obligatorias
missing_fields = !(compulsory_fields %in% names(bicycle_network_gdf))
if (any(missing_fields)) {
  print(paste('Faltan algunas columnas obligatorias en el Dataframe:', compulsory_fields[missing_fields]))
}

# 2. Preproceso y limpieza de geometrías. --------------------------------------

# 2.1. Split de ciclovías
bicycle_network_gdf = split_polylines(
  bicycle_network_gdf,
  id_field='id_2'
)

# 2.2. Split de calles
x_osm_splitter = split_polylines(
  sf::st_read(OSM_SHP_PATH),
  id_field='id_osm'
)

# 2.3. Ejecuta el split de ciclovías con la red de calles
bicycle_network_gdf = split_by_other_polylines(
  bicycle_network_gdf,
  x_osm_splitter,
  id_field='id_2',
)

# 2.4 Unión con red de OSM
total_network_gdf = join_polylines(
  bicycle_network_gdf,
  x_osm_splitter,
  by_feature = F
)


# 3. split con red de calles:
# 3.1. Limpia red de calles aplicando inhibidores y deshinibidores.
x_osm_splitter = apply_disablers (
  x_osm = x_osm_splitter,
  disablers_list = list(
    sf::st_read('data/raw/65f69d7c-a0ee-4ff5-b220-0168a3c2b756202041-1-16ubwo1.mcsv.shp'),
    sf::st_read('data/raw/Primary_seconday.shp')
  ),
  enablers_list = list(
    sf::st_read('data/raw/Semaforos.shp')
  ),
  enabler_buffer_threshold = 10,
  disabler_buffer_threshold = 10
)



sf::write_sf(total_network_gdf,"planarizev1.geojson")
sf::

# 3. Conversión de tipo de dato sf a tipo de dato igraph (tidygraph). ----------
total_igraph_raw = sf_to_igraph(
  total_network_gdf,
  directed = FALSE
)
