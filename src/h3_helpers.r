# to_h3 = function(hex, red, tipo, escenario, data_list, conn ) {
#   
#   print('Intersectando líneas con H3')
#   names(red) = tolower(names(red))
#   names(x) = tolower(names(x))
#   #int = st_intersection(red,x)
#   #print('Calculando largo')
#   #int$len = st_length(int)/1000 #Medida en km
# 
#   #Kilometros totales
#   #Kilometros por topología
#   #Kilometros de cruce
#   #Razón de cruces de cicl ovías
#   if (tipo == 'descriptive') {
#     
#     print('Calculando largo por tipología')
#     int$len_ca = ifelse(int$ci_ca == 1, int$len,0)
#     int$len_vd = ifelse(int$ci_vd == 1, int$len,0)
#     int$len_plat = ifelse(int$ci_plat == 1, int$len,0)
#     int$len_band = ifelse(int$ci_band == 1, int$len,0)
#     int$len_par = ifelse(int$ci_par == 1, int$len,0)
#     int$len_div = ifelse(int$otros_ci == "2", int$len,0)
#     int$len_zig = ifelse(int$otros_ci == "3", int$len,0)
#     int$len_intra = ifelse(int$otros_ci == "4", int$len,0)
#     int$len_lm = ifelse(int$otros_ci == "5", int$len,0)
#     
#     print('Calculando largo de cruces')
#     int$len_cru = ifelse(int$ci_o_cr == 0, int$len,0)
#     
#     x$n_id = 1:nrow(x)
#     
#     join = st_join(x,int)
#     
#     print('Asignando largo a H3')
#     out = group_by(join, n_id) %>%
#       summarize(km_total = sum(len),
#                 km_ca = sum(len_ca),
#                 km_vd = sum(len_vd),
#                 km_plat = sum(len_plat),
#                 km_band = sum(len_band),
#                 km_par = sum(len_par),
#                 km_div = sum(len_div),
#                 km_zig = sum(len_zig),
#                 km_intra= sum(len_intra),
#                 km_lm = sum(len_lm),
#                 km_cru = sum(len_cru)) %>% mutate( .,km_total = ifelse(is.na(km_total),0,km_total) ) %>% st_drop_geometry()
#     
#     numeric_variables = c('km_ca',
#                           'km_vd',
#                           'km_plat',
#                           'km_band',
#                           'km_par',
#                           'km_div',
#                           'km_zig',
#                           'km_intra',
#                           'km_lm',
#                           'km_cru')
#     out[numeric_variables][is.na(out[numeric_variables])] = 0
#   
#     print('Calculando razón de cruces/ciclovias [km]')
#     out$r_cru_ci = out$km_cru/out$km_total
#     
#     
#     
#     
#     result = merge(x, out, by = 'n_id')
#     
#     
#   }
#   #Kilometros de ciclováis buenas
#   #% de ciclovías buenas
#   #Kilometros de ciclovías malas
#   #% de ciclovías malas
#   if (tipo == 'quality') {
#     
#     int$len_ci_b = ifelse(op_ci == 1, int$len, 0)
#     int$len_ci_m = ifelse(op_ci == 0, int$len, 0)
#     int$len_cr_b = ifelse(op_cr == 1, int$len, 0)
#     int$len_cr_m = ifelse(op_cr == 0, int$len, 0)
# 
#     int$per_ci_b = int$len_ci_b/int$len 
#     int$per_ci_m = int$len_ci_m/int$len
#     int$per_cr_b = int$len_cr_b/int$len
#     int$per_cr_m = int$len_cr_m/int$len
# 
#     print('Asignando indicadores de calidad a H3')
# 
#   }
#   
#   #Max Betweenes (arcos)
#   #Promedio Straightness (arcos)
#   #Promedio Clossennes (arcos)
#   #Kilometros del componente más grande -> km del componente más grande 
#   #Número de componentes ->  cantidad de compoinentes distintos que intersectan con h3
#   
#   #Por desarrollar
#   #Kilometros del cluster más grande??
#   #Número de clusters??
#   
#   #Establecer conectividad para cada caso? operativo, inoperativo y proyectado? 
#   if (tipo == 'connectivity') {
#     
#     if (escenario == 'op') {}
#     if (escenario == 'inop') {}
#     if (escenario == 'pro') {}
#     
#     int$max_bet = 
#     int$mean_str =
#     
#     int$km_comp = 
#     int$n_comp =
#     int$km_clus =
#     int$n_clus
#     
#     x$n_id = 1:nrow(x)
#     
#     join = st_join(x,int)
#     
#     print('Asignando largo a H3')
#     out = group_by(join, n_id) %>%
#       summarize(max_bet = max(eb_sub_op),
#                 mean_str = mean(es_sub_op),
#                 )
#   }
#   
#   if (tipo == 'geometry') {
#     
#   }
#   
#   if (tipo == 'componente') {
#     dbSendQuery(conn,
#                 glue("SELECT
#                 {'x'}.id,
#                 {'x'}.
#                 st_intersection({'red'}.geometry,{'x'}.geometry) as geometry
#                 from {'red'}, {'x'}"))
#   }
#   return(result)
# }

##SEPARAR UNIÓN BASAL DE HEXAGONOS CON RESULTADOS POR ESCENARIO##

#' Verificar nombres de columnas de resultado en los hexagonos
#' @param h Nombre del shape de hexagonos
#' @param nombre_escenario Nombre del escenario que se desea verificar
#' @param connec Variable de conexión
check_columns_existence = function(h,nombre_escenario,connec) {
  dbGetQuery(connec,
             glue(
               "SELECT EXISTS (SELECT 1 
                  FROM information_schema.columns 
                  WHERE table_schema='hexs' AND table_name='{h}' AND column_name='{nombre_escenario}_ci_total')"
             ))
}

#' Preparar hexágonos para traspaso de información agregando columnas de resultado
#' @param h_schema Nombre del esquema de hexagonos
#' @param h Nombre del shape de hexágonos
#' @param nombre_resultado Nombre del resultado que se desea agregar a los hexagonos
#' @param connec Variable de conexión 
prepare_hex = function(h_schema,h,nombre_resultado,connec) {
  dbGetQuery(conn = connec,
             glue("ALTER TABLE \"{h_schema}\".\"{h}\"
             add column {nombre_resultado}_id_comp VARCHAR,
             add column {nombre_resultado}_ci_total VARCHAR,
             add column {nombre_resultado}_Fantom VARCHAR,
             add column {nombre_resultado}_project_1 VARCHAR,
             add column {nombre_resultado}_project_2 VARCHAR,
             add column {nombre_resultado}_ci_B VARCHAR,
             add column {nombre_resultado}_ci_M VARCHAR,
             add column {nombre_resultado}_cr_B VARCHAR,
             add column {nombre_resultado}_cr_M VARCHAR,
             add column {nombre_resultado}_ci_N_B VARCHAR,
             add column {nombre_resultado}_ci_N_M VARCHAR,
             add column {nombre_resultado}_metros_OSM VARCHAR"
                  )
             )
}

#' Agregar información de resultados a los hexagonos
#' @param h_schema Nombre de los hexágonos 
#' @param h Nombre de shape de hexágonos
#' @param x Nombre de shape de red
#' @param x_schema Nombre del schema de la red
#' @param connec Variable de conexión
to_h3 = function(h_schema,h,x_schema,x,connec) {
  if (!(check_columns_existence(h,x,connec))) {
    prepare_hex(h_schema,h,x,connec)
  }
  dbGetQuery(connec,
             glue(" 
             UPDATE \"{h_schema}\".\"{h}\"
             set {x}_id_comp = id_comp,
             {x}_ci_total = ci_total,
             {x}_Fantom = Fantom,
             {x}_project_1 = project_1,
             {x}_project_2 = project_2,
             {x}_ci_B = ci_B,
             {x}_ci_M = ci_M,
             {x}_cr_B = cr_B,
             {x}_cr_M = cr_M,
             {x}_ci_N_B = ci_N_B,
             {x}_ci_N_M = ci_N_M,
             {x}_metros_OSM = metros_OSM
             from (
             SELECT 
                pc.*,
                id_comp,
                ci_total,
                Fantom,
                project_1,
                project_2,
                ci_B,
                ci_M,
                cr_B,
                cr_M,
                ci_N_B,
                ci_N_M,
                metros_OSM
              from \"{h_schema}\".\"{h}\" pc
              left join (
                select 
                  id_hex,
                  id_comp
                from (
                  SELECT
                    id_hex,
                    id_comp,
                    row_number() over (partition by id_hex order by largo desc) as rnk,
                    largo
                  from (
                	  select 
                	  	pc.id as id_hex,
                	  	tc.id_comp as id_comp,
                	  	st_intersection(tc.geometry,pc.geometry) as geometry,
                	  	sum(st_length(tc.geometry)) as largo	
                	  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	  where st_intersects(tc.geometry,pc.geometry) = TRUE
                	  group by id_hex,id_comp,tc.geometry,pc.geometry
                  ) as inter
                ) as last
                where rnk = 1) as int
                on pc.id = int.id_hex
              left join (
                select
	                id_hex,
	                sum(st_length(geometry)) as ci_total
                from (
                	select 
                		pc.id as id_hex,
                		tc.id_2 as ci_total,
                		st_intersection(tc.geometry,pc.geometry) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geometry) = TRUE and id_2 is not null
                ) as i_largo_ciclo
                group by id_hex
              ) as len_ci_total
              on pc.id = len_ci_total.id_hex
              left join (
                select
                	id_hex,
                	sum(st_length(geometry)) as Fantom
                from (
                	select 
                		pc.id as id_hex,
                		tc.\"phanto\" as phanto,
                		st_intersection(tc.geometry,pc.geometry) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geometry) = TRUE
                ) as i_p
                where phanto = 1
                group by id_hex
              ) as i_phanto
              on pc.id = i_phanto.id_hex
              left join (
                select
                	id_hex,
                	sum(st_length(geometry)) as project_1
                from (
                	select 
                		pc.id as id_hex,
                		tc.\"proye\" as proye,
                		st_intersection(tc.geometry,pc.geometry) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geometry) = TRUE
                ) as i_p_1
                where proye = 1
                group by id_hex  
              ) as i_project_1
              on pc.id = i_project_1.id_hex
              left join (
                select
                	id_hex,
                	sum(st_length(geometry)) as project_2
                from (
                	select 
                		pc.id as id_hex,
                		tc.\"proye\" as proye,
                		st_intersection(tc.geometry,pc.geometry) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geometry) = TRUE
                ) as i_p_2
                where proye = 2
                group by id_hex
              ) as i_project_2
              on pc.id = i_project_2.id_hex
              left join (
                select
                  id_hex,
                  sum(st_length(geometry)) as ci_B
                from (
                  select 
                   pc.id as id_hex,
                   tc.\"op_ci\" as op_ci,
                   st_intersection(tc.geometry,pc.geometry) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geometry)= TRUE
                ) as i_op_0
                where op_ci = 0
                group by id_hex
              ) as i_op_ci_0
              on pc.id = i_op_ci_0.id_hex
              left join (
                select
                  id_hex,
                  sum(st_length(geometry)) as ci_M
                from (
                  select 
                   pc.id as id_hex,
                   tc.\"op_ci\" as op_ci,
                   st_intersection(tc.geometry,pc.geometry) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geometry)= TRUE
                ) as i_op_1
                where op_ci = 1
                group by id_hex
              ) as i_op_ci_1
              on pc.id = i_op_ci_1.id_hex
              left join (
                select
                  id_hex,
                  sum(st_length(geometry)) as cr_B
                from (
                  select 
                   pc.id as id_hex,
                   tc.\"op_cr\" as op_cr,
                   st_intersection(tc.geometry,pc.geometry) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geometry)= TRUE
                ) as i_cr_0
                where op_cr = 0
                group by id_hex
              ) as i_op_cr_0
              on pc.id = i_op_cr_0.id_hex
              left join (
                select
                  id_hex,
                  sum(st_length(geometry)) as cr_M
                from (
                  select 
                   pc.id as id_hex,
                   tc.\"op_cr\" as op_cr,
                   st_intersection(tc.geometry,pc.geometry) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geometry)= TRUE
                ) as i_cr_1
                where op_cr = 1
                group by id_hex
              ) as i_op_cr_1
              on pc.id = i_op_cr_1.id_hex
              left join (
                select
	                id_hex,
	                sum(st_length(geometry)) as metros_OSM
                from (
                	select 
                		pc.id as id_hex,
                		tc.id_2 as id_2,
                		st_intersection(tc.geometry,pc.geometry) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geometry) = TRUE and id_2 is null
                ) as i_largo_osm
                group by id_hex
              ) as len_osm_total
              on pc.id = len_osm_total.id_hex
              left join (
                  select
			              id_hex,
		                largo as ci_n_b
	                from (	
				            select 
				              id_hex,
				              row_number() over (partition by id_hex order by largo desc) as rnk,
				              largo
				            from( 
				              SELECT
                        id_hex,
                        n_ciclo,
                        sum(st_length(tc.geometry)) as largo
                      from (
                    	  select 
                    	  	pc.id as id_hex,
                    	  	tc.\"n_ciclo\" as n_ciclo,
                    	  	tc.\"op_ci\" as op_ci,
                          st_intersection(tc.geometry,pc.geometry) as geometry
                        from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                        where st_intersects(tc.geometry,pc.geometry) = TRUE
                        group by id_hex,n_ciclo,op_ci,tc.geometry,pc.geometry
                      ) as inters
				            where n_ciclo is not null and op_ci = 0
				            group by id_hex,n_ciclo
				            ) as ciclo_n
				            ) as ciclovian
				        where rnk = 1) as len_ci_n_b
                on pc.id = len_ci_n_b.id_hex
                left join (
                  select
			              id_hex,
		                largo as ci_n_m
	                from (	
				            select 
				              id_hex,
				              row_number() over (partition by id_hex order by largo desc) as rnk,
				              largo
				            from( 
				              SELECT
                        id_hex,
                        n_ciclo,
                        sum(st_length(inters.geometry)) as largo
                      from (
                    	  select 
                    	  	pc.id as id_hex,
                    	  	tc.\"n_ciclo\" as n_ciclo,
                  	  	  tc.\"op_ci\" as op_ci,
                          st_intersection(tc.geometry,pc.geometry) as geometry
                        from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                        where st_intersects(tc.geometry,pc.geometry) = TRUE
                        group by id_hex,n_ciclo,op_ci,tc.geometry,pc.geometry
                      ) as inters
				            where n_ciclo is not null and op_ci = 1
				            group by id_hex,n_ciclo
				            ) as ciclo_n
				            ) as ciclovian
				        where rnk = 1) as len_ci_n_m
                on pc.id = len_ci_n_m.id_hex
                  ) result
                  where \"{h_schema}\".\"{h}\".id = result.id"
             )
  )
  
  }

#' Borrar columnas de escenario específico en los hexágonos
#' @param h Nombre del shp de hexagonos
#' @param nombre_escenario Nombre del escenario que se desea borrar
#' @param connec Variable de conexión
delete_h3_results = function(h,nombre_escenario,connec) {
  dbGetQuery(conn = connec,
             glue("ALTER TABLE hexs.\"{h}\"
             drop column {nombre_escenario}_id_comp,
             drop column {nombre_escenario}_ci_total,
             drop column {nombre_escenario}_Fantom,
             drop column {nombre_escenario}_project_1,
             drop column {nombre_escenario}_project_2,
             drop column {nombre_escenario}_ci_B,
             drop column {nombre_escenario}_ci_M,
             drop column {nombre_escenario}_cr_B,
             drop column {nombre_escenario}_cr_M,
             drop column {nombre_escenario}_ci_N_B,
             drop column {nombre_escenario}_ci_N_M,
             drop column {nombre_escenario}_metros_OSM"
             )
  )
} 