# Autor: Ignacio Hernández Cartagena
# E-mail: matias.duran@usach.cl
# Fecha: enero, 2022
# 
# Descripcion: Este archivo contiene el flujo de ejecucion para implementar el
# algoritmo de analisis de indicadores y metricas de red sobre redes de
# ciclovias.
#
# Indice -----------------------------------------------------------------------
# 0. Importacion de librerias y funciones.
# 1. Lectura de archivos de entrada (formato *.shp o *.geojson).
# 2. Preproceso y limpieza de geometrías.
# 3. Conversión de tipo de dato sf a tipo de dato igraph (tidygraph).
# 4. Filtro de dataset según escenario.
# 5. Cálculo de indicadores
# 5.1. Se agrega un identificador de componente a cada arco.
# 5.2. Calcula indicadores para el caso general.
# 5.3. Calcula indicadores para cada subcomponente.
# 5.3.1. Casos operativos; gi_comp: id_c|largo_t|largo_prom|beta_index|diametro|
#                                   n_sub_comp
# 5.3.2. Casos inoperativos; gsub_inop_comp:  id_c_sub_inop|id_c|largo_t|
#                                             largo_prom|c_close|c_betwee|
#                                             c_straigth
# 5.3.3. Casos proyectados: gsub_pro_co:  id_c_sub_pro|id_c|largo_t|largo_prom|
#                                         c_close|c_betwee|c_straigth
# 5.4. Count the number of subcomponents for each component
# 6. Exportación de archivos en formato *.csv y *.geojson.
# 6.1. gi_comp: id_component|largo_t|largo_prom|beta_index|diametro|
#               c_betweenness|c_closeness|c_straightness|n_gsub_op_comp|
#               n_gsub_inop_comp|n_gsub_pro_com
# 6.2. gsub_op_comp:  id_component|largo_t|largo_prom|beta_index|diametro|
#                     c_betweenness|c_closeness|c_straightness
# 6.3. gsub_inop_comp:  id_component|largo_t|largo_prom|beta_index|diametro|
#                       c_betweenness|c_closeness|c_straightness
# 6.4. gsub_pro_com:  id_component|largo_t|largo_prom|beta_index|diametro|
#                     c_betweenness|c_closeness|c_straightness
# 6.5. gi_aristas (tabla CSV):  from|to|id_aris|id_2|id_c|weight|id_c_sub_op|
#                               eb_sub_op|ec_sub_op|es_sub_op|d_sub_op|
#                               id_c_sub_inop|eb_sub_inop|ec_sub_inop|
#                               es_sub_inop|d_sub_inop|id_c_sub_pro|
#                               eb_sub_pr|ec_sub_pr|es_sub_pr|d_sub_pr
# 6.6. gi_aristas (tabla GeoJSON):  from|to|id_aris|id_2|id_c|weight|id_c_sub_op|
#                                   eb_sub_op|ec_sub_op|es_sub_op|d_sub_op|
#                                   id_c_sub_inop|eb_sub_inop|ec_sub_inop|
#                                   es_sub_inop|d_sub_inop|id_c_sub_pro|
#                                   eb_sub_pr|ec_sub_pr|es_sub_pr|d_sub_pr
# 6.7. Exportacion de un archivo geojson por cada componente.

# 0. Importacion de librerias y funciones -------------------------------------
packages <- c("here","dplyr","sf","igraph","lwgeom","rgdal")
install.packages(setdiff(packages,rownames(installed.packages())))
library(here)        # Gestionar rutas relativas
library(dplyr)       # Trabajar con dataframes
library(sf)          # Trabajar con simple features
library(rgdal)
library(igraph)      # Construir grafos
library(tidygraph)   # Manipular grafos en formato de tablas
library(lwgeom)      # Para utilizar la funcion st_split()
#

# -----------------------------------------------------------------------------
# ruta de carpeta en donde se localiza el archivo "calculate_metrics.R"
# por ejemplo, en este caso el archivo estria en:
#   c:/ruta/del/archivo/calculate_metrics.R
# y la ruta de la carpeta seria:
#   c:/ruta/del/archivo/
#setwd('~/home/grafos-accesibilidad/')
# -----------------------------------------------------------------------------

source(file = here('src/graph_helpers.R'))
source(file = here("src/sql_helper.R"))
source(file = here('config.R'))

# Algoritmo y ejecucion --------------------------------------------------------
# 1. Lectura de archivos de entrada (formato *.shp o *.geojson). ---------------

#Nombre database
dsn_database = "gis"
#Dirección de host (localhost)
dsn_hostname = "172.17.0.2"
#Puerto habilitado para PostgreSQL
dsn_port = 5432
#Usuario y contraseña para BBDD
dsn_uid = "masciclo"
dsn_pwd = "Masciclo2022"

#Crear string de conexión
dsn = paste0("PG:dbname='",dsn_database,"' host='",dsn_hostname,"' user='",dsn_uid,"' password='",dsn_pwd,"'")

components = function(red) {
topologia = paste0(red,"_topo")
#Importar el archivo desde la base de datos y transformarlo a sf
print("CARGANDO RED PRINCIPAL")
total_network_gdf = st_read(dsn = dsn,
                            query = glue("select
                     rcc.\"OBJECTID_1\",
 	                   rcc.\"COMUNA\",
 	                   rcc.\"CI_O_CR\",
 	                   rcc.\"TIP_VIA_CI\",
 	                   rcc.\"ANCHO_V\",
 	                   rcc.\"T_SEG_VD\",
 	                   rcc.\"T_SEG_CA\",
 	                   rcc.\"CI_VD\",
 	                   rcc.\"CI_PAR\",
 	                   rcc.\"CI_S_PAR\",
 	                   rcc.\"CI_CA\",
 	                   rcc.\"OTROS_CI\",
 	                   rcc.\"MATERIAL\",
 	                   rcc.\"VEG\",
 	                   rcc.\"T_VIA_CR\",
 	                   rcc.\"SEÑALIZAD\",
 	                   rcc.\"PINTADO\",
 	                   rcc.\"SEMAFORO\",
 	                   rcc.\"CARTEL\",
 	                   rcc.\"OTROS_CR\",
 	                   rcc.\"CICLOV\",
 	                   rcc.\"DISCON\",
 	                   rcc.\"LINEAS_P\",
 	                   rcc.\"COLOR_P\",
 	                   rcc.\"ANCHO_S\",
 	                   rcc.\"CI_PLAT\",
 	                   rcc.\"CI_BAND\",
 	                   rcc.\"PHANTO\",
 	                   rcc.\"COMP\",
 	                   rcc.largo_m,
 	                   rcc.\"Shape_Leng\",
 	                   rcc.\"DISCON_CR\",
 	                   rcc.\"ONEWAY\",
 	                   rcc.\"Id\",
 	                   rcc.\"CICLOVIA_N\",
 	                   rcc.\"PISTAS_VIA\",
 	                   rcc.\"ANCHO_VIA\",
 	                   rcc.\"TIPCI\",
 	                   rcc.\"FECHA_CI\",
 	                   rcc.\"ID_2\",
 	                   rcc.proyect,
 	                   rcc.o_op_ci,
 	                   rcc.o_op_cr,
 	                   rcc.tipologia,
 	                   rcc.\"type\",
 	                   rcc.\"name\",
 	                   rcc.oneway,
 	                   rcc.\"V_PRIV\",
 	                   rcc.\"T_PRIV\",
 	                   rcc.\"T_CAM\",
 	                   rcc.\"V_CAM\",
 	                   rcc.\"T_BICI\",
 	                   rcc.ciclo_calle,
  e.geom as geometry from
{red} rcc,
{topologia}.edge e,
{topologia}.relation rel
where e.edge_id = rel.element_id and rel.topogeo_id = (rcc.topo_geom).id")
                            )
#Eliminar geometrías vacías y estandarización de campos
total_network_gdf = total_network_gdf[!sf::st_is_empty(total_network_gdf$geometry),] 
names(total_network_gdf) = tolower(names(total_network_gdf))

# Validar columnas obligatorias
missing_fields = !(compulsory_fields %in% names(total_network_gdf))
if (any(missing_fields)) {
  print(paste('Faltan algunas columnas obligatorias en el Dataframe:', compulsory_fields[missing_fields]))
}

# Forzar nombres únicos
colnames(total_network_gdf) = make.names(colnames(total_network_gdf), unique = T)

# 3. Conversión de tipo de dato sf a tipo de dato igraph (tidygraph). ----------
print("TRANSFORMANDO A GRAPHO")
total_igraph_raw = sf_to_igraph(
  total_network_gdf,
  directed = FALSE
)

# 4. Filtro de dataset según escenario. ----------------------------------------
#Primero se filtran los no existentes.
#bicycle_igraph = total_igraph_raw %>%
#  activate(edges) %>%
#  filter(!eval(settings_list[[settings]]$filter_non_existent)) %>%
#  activate(nodes) %>%
#  filter(!node_is_isolated())


# 5. Cálculo de indicadores ----------------------------------------------------

# 5.1. Se agrega un identificador de componente a cada arco. -------------------
print("CALCULANDO COMPONENTES")
bicycle_igraph = total_igraph_raw %>%
  add_components(field_name='id_comp')

bicycle_tibble = bicycle_igraph %>% as_tibble

componentes_ciclables = as.data.frame(unlist(lapply( unique(bicycle_tibble$id_comp), function(x) {
  any(bicycle_tibble[bicycle_tibble$id_comp == x,]$ciclo_calle)
})))

componentes_ciclables$id = c(1:nrow(componentes_ciclables))
colnames(componentes_ciclables)[1] = "componente_ciclable"
bicycle_tibble = merge(bicycle_tibble,componentes_ciclables,by.x='id_comp',by.y='id')

return(bicycle_tibble)
}

for (setting in settings_list) {
  result = components(setting$nombre_resultado)
  sf::st_write(result,layer = setting$nombre_resultado, dsn = connec)
  create_spatial_index(setting$nombre_resultado,'geometry',connec)
}
