library(DBI)
library(RPostgreSQL)
library(glue)
library(rgdal)

source(file = here('config.R'))

dsn = paste0("PG:dbname='",dsn_database,"' host='",dsn_hostname,"' user='",dsn_uid,"' password='",dsn_pwd,"'")

#' Prueba y conecta con la base de datos entregando como resultado una variable de conexión
#' @param db Nombre de la base de datos 
#' @param host IP de la base de datos
#' @param port Puerto de la base de datos (Por defecto en PostgreSQL es 5432)
#' @param usr Usuario
#' @param pass Contraseña
#' @param conn Variable de conexión
test_database_conection <- function(db, host, port, usr, pass) {
  tryCatch({
    drv <- dbDriver("PostgreSQL")
    print("Connecting to Database…")
    connec <- dbConnect(drv, 
                        dbname = db,
                        host = host, 
                        port = port,
                        user = usr, 
                        password = pass)
    print("Database Connected!")
  },
  error=function(cond) {
    print("Unable to connect to Database.")
  })
  return(connec)
}


#' Importa un shape a la base de datos
#' @param shp Shape a importar a la base de datos
#' @param db Nombre del shape dentro de la base de datos
#' @param conn Variable de conexión
import_shape_to_database = function(shp,db,conn) {
  tryCatch({
    dbWriteTable(connec,db,shp, overwrite = TRUE)
  })
}

#' Verifica la existencia de una tabla
#' @param table Nombre de la tabla a verificar
#' @param conn Variable de conexión
check_table_existence = function(table,conn) {
  return(ifelse(
    nrow( dbGetQuery(connec, glue("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '{table}';")) ) > 0,
    T, 
    F))
}

#' Crea y limpia la topología de la red
#' @param shps Nombre de la red dentro de la base de datos
#' @param topo_name Nombre de la topología de la red
#' @param srid Código de sistema de coordenadas (Para el caso de Santiago corresponde a "32719")
#' @param geometry Nombre del campo correspondiente a la geometría
#' @param conn Variable de conexion
create_and_clean_topology = function(shp,topo_name,srid,connec,geometry) {
  init_time = Sys.time()
  dbSendQuery(connec,glue(
             "SELECT topology.CreateTopology('{topo_name}',{srid});
              SELECT topology.AddTopoGeometryColumn('{topo_name}','public','{shp}','topo_geom','LINESTRING');
              update {shp} set topo_geom = topology.toTopoGeom({geometry},'{topo_name}',1,0.001);")
  )
  finish_time = Sys.time()
  print("Tiempo empleado en cortar la topología:")
  print(finish_time-init_time)
}


#' Crea los buffers que serán utilizados para cortar los inhibidores.
#' @param lista_shps Nombre de las capas a las cuales se les aplicará el buffer
#' @param metros Metros de buffer
#' @param conn Variable de conexion
create_buffer = function( lista_shps, metros = 0 , connec ) {
  
  #Colapsar nombres de capas
  collapse_shps_names = paste(lista_shps,collapse='_') # lista_shps = c(ciclo,principales) -> ciclo_principales
  
  #Asigna nombre del buffer segun el largo asignado
  buffer_name = paste(collapse_shps_names,metros,sep='_') #collapse_shps = ciclo_principales, metros = 10 -> ciclos_principales_10 
  
  #Asigna el nombre del indice espacial
  index_name = paste0(buffer_name,'_idx')
  
  #Revisa si el nombre de la tabla ya existe en la base de datos
  table_existence = ifelse(
    nrow( dbGetQuery(connec, glue("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '{buffer_name}';")) ) > 0,
    T, 
    F)
  #Si existe, no retorna nada y carga el buffer a la consulta
  if (table_existence) {
    print(paste0("Cargando buffer ",buffer_name))
    create_spatial_index = dbSendQuery(connec,
                                       glue("CREATE INDEX IF NOT EXISTS {index_name} ON {buffer_name} USING GIST (geometry);"))
    estado = T
    return(buffer_name)
  }
  #Si no existe, lo crea y le asigna un indice espacial
  else {
    if (metros != 0) {
      print("Creando buffer")
      buffer_sql =  paste(
        lapply(
          lista_shps,function(x) 
            glue("select st_union(st_buffer({x}.geometry,{metros})) as geometry FROM public.{x}")),
        collapse = ' union all ')
      buffer_query = dbSendQuery(connec,
                               glue("CREATE TABLE {buffer_name} AS {buffer_sql};"))
      create_spatial_index = dbSendQuery(connec,
                                       glue("CREATE INDEX {index_name} ON {buffer_name} USING GIST (geometry);"))
      return(buffer_name)
    }
    else{
      return(FALSE)
    }
  }
}



#' Corta el buffer de inhibidores con el de desinhibidores
#' @param nombre_resultado Nombre del resultado final del proceso
#' @param buffer_inhibidores Nombre del buffer de inhibidores
#' @param buffer_desinhibidores Nombre del buffer de desinhibidores
#' @param conn Variable de conexion
buffer_difference = function(nombre_resultado,buffer_inhibidores,buffer_desinhibidores,conn) {
  
    dbSendQuery(conn,glue("CREATE TABLE IF NOT EXISTS bf_{nombre_resultado} as
                                  select 
                                  st_difference(bi.geometry,bd.geometry) as geometry
                                  from {buffer_inhibidores} bi, {buffer_desinhibidores} bd;
                                  
                                  create index IF NOT EXISTS idx_bf_{nombre_resultado}
                                  on bf_{nombre_resultado}
                                  using GIST(geometry);")
    )
  return("bf_{nombre_resultado}")
}


#' Corta la red según los buffer de inhibidores y/o desinhibidores.
#' @param nombre_resultado Nombre de la red que se almacenará en la base de datos 
#' @param red Red que será cortada por los buffers.
#' @param filters Filtros que se aplicarán a la red
#' @param lista_inh Nombre de capas que serán usadas como inhibidores.
#' @param buffer_inh Metros de buffer para los inhibidores.
#' @param lista_des  Nombre de capas que serán usadas como desinhibidores.
#' @param buffer_des Metros de buffer para los desinhibidores.
#' @param conn Variable de conexion.
#' @return Un dataframe con las polilineas que intersectan subdivididas.
cut_intermodal_network = function(nombre_resultado, red, filters = c(), lista_inh = c(),buffer_inh = 0,lista_des = c(),buffer_des = 0,conn) {
  
  init_time = Sys.time()
  
  #Crear buffer de inhibidores
  buffer_inhibidores = create_buffer(lista_inh,buffer_inh,conn)
  #Crear buffer de desinhibidores
  buffer_desinhibidores = create_buffer(lista_des,buffer_des,conn)
  #Crear buffer final
  print("Cortando buffer de inhibidores")
  buffer_final = buffer_difference(nombre_resultado,buffer_inhibidores,buffer_desinhibidores,conn)
  
  print("Cortando la red")
  
  if (is.null(filters)) {
    finalQuery = glue("create table {nombre_resultado} as 
                    select
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
 	                   rcc.\"Shape_Le_1\",
 	                   rcc.\"T_BICI\",
 	                   rcc.ciclo_calle,
                     st_difference(rcc.geometry, bf.geometry) as geometry
                    from {red} rcc, bf_{nombre_resultado} bf;
                    
                    create index idx_{nombre_resultado}
                    on {nombre_resultado}
                    using GIST(geometry);")
  }
  else {
    filter_stament = paste(filters, collapse = ' and ')
    finalQuery = glue("create table {nombre_resultado} as 
                    select
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
 	                   rcc.\"Shape_Le_1\",
 	                   rcc.\"T_BICI\",
 	                   rcc.ciclo_calle,
                     st_difference(rcc.geometry, bf.geometry) as geometry
                    from {red} rcc, bf_{nombre_resultado} bf
                    where {filter_stament};
                    
                    create index idx_{nombre_resultado}
                    on {nombre_resultado}
                    using GIST(geometry);")
  }

  
  dbSendQuery(conn,finalQuery)
  
  create_and_clean_topology(shp = nombre_resultado,
                            topo_name = paste0(nombre_resultado,"_topo"),
                            srid = srid,
                            connec = conn,
                            geometry = 'geometry')
  
  finish_time = Sys.time()
  print("Tiempo total:")
  print(finish_time-init_time)
  
  
}

#' Actualiza el SRID una vez modificada las coordenadas de geometría
#' @param shp Nombre del shape al cual se le modificara el SRID
#' @param srid Código SRID nuevo
#' @param conn Variable de conexión 
update_srid = function(shp, srid, conn) {
  dbGetQuery( conn = conn,statement = glue("SELECT UpdateGeometrySRID('{shp}','geometry',{srid});") ) 
}

#' Cambia el sistema de coordenadas de una red
#' @param shp Nombre de la red al cual se le modificaran las coordenadas
#' @param new_coords Sistema de coordenadas nuevo
#' @param old_coords Sistema de coordenadas nuevo
#' @param conn Variable de conexión
change_geometry = function( shp, new_coords, old_coords, conn ) {
  dbGetQuery(conn = conn, statement = glue ("ALTER TABLE {shp} ALTER COLUMN geometry TYPE Geometry(LINESTRING, {new_coords}) USING ST_Transform(geometry,{new_coords});"))
}

#' Agrega indice espacial a la base
#' @param nombre_tabla Nombre de la tabla a la cual se le agregará el índice espacial
#' @param geometry Nombre del campo correspondiente a la geometria
create_spatial_index = function( nombre_tabla, geometry = 'geometry', conn) {
  dbSendQuery(conn,
              glue("create index idx_{nombre_tabla}
                    on {nombre_tabla}
                    using GIST({geometry});")
              )
}