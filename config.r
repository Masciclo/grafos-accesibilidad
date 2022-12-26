library(here)

##VARIABLES DE CONEXIÓN CON LA BASE DE DATOS
dsn_database = "gis"
dsn_hostname = "172.17.0.2"
dsn_port = 5432
dsn_pwd = "Masciclo2022"
dsn_uid = "masciclo"

dsn = paste0("PG:dbname='",dsn_database,"' host='",dsn_hostname,"' user='",dsn_uid,"' password='",dsn_pwd,"'")
connec = test_database_connection(dsn_database,dsn_hostname,dsn_port,dsn_uid,dsn_pwd)

#SRID 
srid = 32719

##NOMBRE BASE OSM RAW
###OJO! NO USAR 
OSM_RAW_BD_NAME = ""

##NOMBRE EN BASE DE DATOS RED
CICLO_BD_NAME = "ciclo_eje_mapocho" 
OSM_BD_NAME ="Residencial_y_servicio_ eje_mapocho"

##NOMBRE EN BASE DE DATOS INHIBIDORES
RED_BUSES_NAME = 'red_buses'
RED_PRINCIPALES_NAME = 'calles_principales'
RED_EJE_MAPOCHO = 'inhibidores_eje_mapocho'

##SHP DESINHIBIDORES
SEMAFOROS_NAME = ''


##NOMBRE EN BASE DE DATOS DE RESULTADO SALIDA RED INTERMODAL
NETWORK_BD_NAME = "red_mapocho"

##NOMBRE EN BASE DE DATOS DE RESULTADO SALIDA DE ESCENARIOS
NOMBRE_RESULTADO_ESCENARIO_1 = 'red_mapocho_cortada'

##HEXAGONOS
HEX_NAME = 'Hexagonos_H3_NSE'

##SCHEMAS
H_SCHEMA = 'hexs'

LOCAL_CUTOFF = 500 # Distancia en metros

settings_list = list(
  setting_1_base = list(
    nombre_resultado = NOMBRE_RESULTADO_ESCENARIO_1,
    red = NETWORK_BD_NAME,
    filters = c("proyect = 0 or proyect isnull "),
    lista_inh = RED_EJE_MAPOCHO,
    buffer_inh = 10,
    lista_des = CICLO_BD_NAME,
    buffer_des = 25,
    connec = connec
  )
)

compulsory_fields = c('id_2', 'phanto', 'proyect', 'op_ci', 'op_cr', 'tip_op')
