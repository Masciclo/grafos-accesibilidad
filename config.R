library(here)

##VARIABLES DE CONEXIÓN CON LA BASE DE DATOS
dsn_database = "gis"
dsn_hostname = "172.17.0.2"
dsn_port = 5432
dsn_pwd = "Masciclo2022"
dsn_uid = "masciclo"

#SRID 
srid = 32719

##NOMBRE BASE OSM RAW
OSM_RAW_BD_NAME = ""

##NOMBRE EN BASE DE DATOS
CICLO_BD_NAME = "ciclo_rm" 
OSM_BD_NAME ="osm_rm"

##NOMBRE EN BASE DE DATOS
RED_BUSES_NAME = 'red_buses'
RED_PRINCIPALES_NAME = 'calles_principales'

##SHP DESINHIBIDORES
SEMAFOROS_NAME = ''

##NOMBRE EN BASE DE DATOS
NETWORK_BD_NAME = "full_net"

##HEXAGONOS
HEX_NAME = 'Hexagonos_H3_NSE'

##SCHEMAS
H_SCHEMA = 'hexs'

LOCAL_CUTOFF = 500 # Distancia en metros

settings_list = list(
  setting_1_base = list(
    nombre_resultado = 'red_total',
    red = NETWORK_BD_NAME,
    filters = c("proyect = 0 or proyect isnull"),
    lista_inh = RED_PRINCIPALES_NAME,
    buffer_inh = 10,
    lista_des = "proyect",
    buffer_des = 25,
    conn = connec
  ),
  setting_2_base = list(
    nombre_resultado = 'red_totalv2',
    red = NETWORK_BD_NAME,
    filters = c("proyect = 0"),
    lista_inh = RED_PRINCIPALES_NAME,
    buffer_inh = 10,
    lista_des = "proyect",
    buffer_des = 25,
    conn = connec
  )
)

compulsory_fields = c('id_2', 'phanto', 'proyect', 'op_ci', 'op_cr', 'tip_op')
