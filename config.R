library(here)

##VARIABLES DE CONEXIÓN CON LA BASE DE DATOS
dsn_database = "gis"
dsn_hostname = "172.17.0.2"
dsn_port = 5432
dsn_pwd = "Masciclo2022"
dsn_uid = "masciclo"

#SRID 
srid = 32719

##SHP PARA RED INTERMODAL
CICLO_SHP_PATH = here("data/raw/Catastro 01-10-2022 con calidad/Catastro_01-10-2022_con_calidad.shp")
OSM_SHP_PATH = here("data/Osm calles/Osm_calles.shp")
##NOMBRE EN BASE DE DATOS
CICLO_BD_NAME = "ciclo_rm" 
OSM_BD_NAME ="osm_rm"

##SHP INHIBIDORES
RED_BUSES_PATH = here("data/raw/06) Shapes 27Ago2022/Shapes 27Ago2022.shp")
RED_PRINCIPALES_PATH = here("data/raw/red_principal.shp")

##NOMBRE EN BASE DE DATOS
RED_BUSES_NAME = 'red_buses'
RED_PRINCIPALES_NAME = 'calles_principales'

##SHP DESINHIBIDORES
SEMAFOROS_PATH = here("data/raw/semaforos.shp")
SEMAFOROS_NAME = ''

##NOMBRE EN BASE DE DATOS
NETWORK_BD = "full_net"

OUTPUT_PATH = here('data/output')
LOCAL_CUTOFF = 500 # Distancia en metros

selected_setting = 'setting_1_base'

settings_list = list(
  setting_1_base = list(
    filter_non_existent = expression(pull(., 'phanto') == 1 | pull(., 'proyect') == 1),
    filter_inoperative = FALSE,
    filter_projected = FALSE
  ),
  escenario_2 = list(
    filter_non_existent = FALSE,
    filter_inoperative = FALSE,
    filter_projected = FALSE
  ),
  escenario_3 = list(
    filter_non_existent = expression(pull(., 'phanto') == 1 | pull(., 'proyect') == 1 ),
    filter_inoperative = FALSE,
    filter_projected = FALSE
  ),
  escenario_7 = list(
    filter_non_existent = expression(pull(., 'phanto') == 1 | pull(., 'proyect') == 1 | pull(.,'o_op_ci') != 1),
    filter_inoperative = FALSE,
    filter_projected = FALSE
  ),
  setting_5_proyectado = list(
    filter_non_existent = expression(pull(., 'phanto') == 1 | pull(., 'op_ci') == 0),
    filter_inoperative = FALSE,
    filter_projected = expression(pull(., 'proyect') == 1)
  )
)

compulsory_fields = c('id_2', 'phanto', 'proyect', 'op_ci', 'op_cr', 'tip_op')
