library(here)

#3.3.1 Base de datos
#-------------------

dsn_database = "gis"
dsn_hostname = "172.17.0.2"
dsn_port = 5432
dsn_pwd = "Masciclo2022"
dsn_uid = "masciclo"

dsn = paste0("PG:dbname='",dsn_database,"' host='",dsn_hostname,"' user='",dsn_uid,"' password='",dsn_pwd,"'")
connec = test_database_connection(dsn_database,dsn_hostname,dsn_port,dsn_uid,dsn_pwd)

#3.3.2 SRID
#-----------

srid = 32719

#3.3.3 Nombre de tablas
#----------------------

#IMPUTS

#a) Shape comodin
SHP_VACIO = 'shape_comodin'

##b) Red de ciclovia y red ciclable
CICLO_BD_NAME = "catastro_22_12_2022" 
OSM_BD_NAME ="osm_lts2"

##c) Inhibidores
RED_BUSES_NAME = 'inhibidor_transantiago_corregido'
RED_PRINCIPALES_NAME = 'inhibidores_calles_principales'
RED_EJE_MAPOCHO = 'inhibidores_eje_mapocho'

##d) Deshinibidores
SEMAFOROS_NAME = ''
INHIBI_CICLO_BD = "desinhibidor_catastro_22_12_2022" 

#OUTPUTS

##a) red tologica
NETWORK_BD_NAME = "red_stg_2"

##b) escenarios

NOMBRE_RESULTADO_ESCENARIO_1 = 'red_stg_2_completa'
NOMBRE_RESULTADO_ESCENARIO_2 = 'red_stg_2_con_calles'
NOMBRE_RESULTADO_ESCENARIO_3 = 'red_stg_2_ciclo'
NOMBRE_RESULTADO_ESCENARIO_4 = 'red_stg_2_ciclo_calidad'

# c) #HEXAGONOS
HEX_NAME = 'Hexagonos_H3_NSE'

##d) SCHEMA
H_SCHEMA = 'hexs'

LOCAL_CUTOFF = 500 # Distancia en metros

settings_list = list(
  setting_1_base = list(
    nombre_resultado = NOMBRE_RESULTADO_ESCENARIO_1,
    red = NETWORK_BD_NAME,
    filters = c("ci_o_cr isnull"),
    lista_inh = SHP_VACIO,
    buffer_inh = 12,
    lista_des = SHP_VACIO,
    buffer_des = 25,
    connec = connec
  ),
  setting_2_base = list(
    nombre_resultado = NOMBRE_RESULTADO_ESCENARIO_2,
    red = NETWORK_BD_NAME,
    filters = c("ci_o_cr isnull"),
    lista_inh = RED_PRINCIPALES_NAME,
    buffer_inh = 12,
    lista_des = SHP_VACIO,
    buffer_des = 25,
    connec = connec
  ),
  setting_3_ciclo = list(
    nombre_resultado = NOMBRE_RESULTADO_ESCENARIO_3,
    red = NETWORK_BD_NAME,
    filters = c("proye = 0 or proye isnull "),
    lista_inh = RED_PRINCIPALES_NAME,
    buffer_inh = 12,
    lista_des = INHIBI_CICLO_BD,
    buffer_des = 25,
    connec = connec
  ),
  setting_4_ciclo_calidad = list(
    nombre_resultado = NOMBRE_RESULTADO_ESCENARIO_4,
    red = NETWORK_BD_NAME,
    filters = c("(proye = 0 or proye isnull) and (op_ci = 0 or op_ci isnull)"),
    lista_inh = RED_PRINCIPALES_NAME,
    buffer_inh = 12,
    lista_des = INHIBI_CICLO_BD,
    buffer_des = 25,
    connec = connec
  )
)

compulsory_fields = c('id_2', 'phanto', 'proyect', 'op_ci', 'op_cr', 'tip_op')