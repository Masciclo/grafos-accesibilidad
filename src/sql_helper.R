library(DBI)
library(RPostgreSQL)
library(glue)
library(rgdal)

dsn_database = "gis"
dsn_hostname = "172.17.0.2"
dsn_port = 5432
dsn_pwd = "Masciclo2022"
dsn_uid = "masciclo"

dsn = paste0("PG:dbname='",dsn_database,"' host='",dsn_hostname,"' user='",dsn_uid,"' password='",dsn_pwd,"'")

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

import_shape_to_database = function(shp,db,connec,encoding) {
  tryCatch({
    dbWriteTable(connec,db,shp)
  })
}

update_srid = function(shp, srid, conn) {
  dbGetQuery( conn = conn,statement = glue("SELECT UpdateGeometrySRID('{shp}','geometry',{srid});") ) 
}

change_geometry = function( shp, new_coords, old_coords, conn ) {
  dbGetQuery(conn = conn, statement = glue ("ALTER TABLE {shp} ALTER COLUMN geometry TYPE Geometry(LINESTRING, {new_coords}) USING ST_Transform(geometry,{new_coords});"))
}

create_and_clean_topology = function(shp,topo_name,srid,connec,geometry) {
  SQL_CREATE_TOPO = glue("SELECT topology.CreateTopology('{topo_name}',{srid});")
  dbGetQuery(connec,SQL_CREATE_TOPO)
  
  SQL_ADD_TOPO = glue("SELECT topology.AddTopoGeometryColumn('{topo_name}','public','{shp}','topo_geom','LINESTRING');")
  dbGetQuery(connec,SQL_ADD_TOPO)
  
  SQL_UPDATE_GEOM = glue("SET max_parallel_workers = 8; SET max_parallel_workers_per_gather = 4; EXPLAIN ANALYZE
                         UPDATE {shp} SET topo_geom = topology.toTopoGeom({geometry},'{topo_name}', 1, 0.001);")
  dbGetQuery(connec,SQL_UPDATE_GEOM)
}


#' Corta la red según los buffer de inhibidores y/o desinhibidores.
#' @param nombre_resultado Nombre de la red que se almacenará en la base de datos 
#' @param red Red que será cortada por los buffers.
#' @param id_field Nombre de columna con id unico para cada geometria.
#' @param geom_precision Precision.
#' @return Un dataframe con las polilineas que intersectan subdivididas.
#' @export
#' @examples
#' split_polylines(bicycle_network_gdf, id_field='id_2')
cut_intermodal_network = function(nombre_resultado ,red, lista_inh,buffer_inh, lista_des,buffer_des,conn) {
  
  
  #Crear buffer de inhibidores
  buffer_inhibidores =  paste(lapply(lista_inh,function(x) glue("select st_union(st_buffer({x}.geometry,{buffer_inh})) as geometry FROM public.{x}")), collapse = ' union all ')
  buffer_desinhibidores = paste(lapply(lista_des,function(x) glue("select st_union(st_buffer({x}.geometry,{buffer_des})) as geometry FROM public.{x}")), collapse = ' union all ')
  finalQuery = glue("create table '{nombre_resultado}' with
                    buffer_i as {buffer_inhibidores},
                    buffer_d as {buffer_desinhibidores},
                    buffer_final as (select st_difference(buffer_i.geometry, buffer_d.geometry)
                    as geometry from buffer_i, buffer_d)
                    select 
                     r.o_op_ci,
                     r.o_op_cr,
                     r.proyect,
                     st_difference(r.geometry, bf.geometry) as geometry
                    from {red} r, buffer_final bf;")
  return(dbSendQuery(conn,finalQuery))
}

cut_intermodal_network(lista_inh = c('buses'),buffer_inh = 10)
