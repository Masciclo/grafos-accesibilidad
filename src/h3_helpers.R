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

#' @param nombre_resultado Nombre de la base de datos 
#' @param h Nombre de shape de hexágonos
#' @param x Nombre de shape de red
#' @param conn Variable de conexión
to_h3 = function(h_schema,h,x_schema,x,conn) {
  dbGetQuery(connec,
             glue("create table {x}_hexs as
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
                	  	st_intersection(tc.geometry,pc.geom) as geometry,
                	  	sum(st_length(geometry)) as largo	
                	  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	  where st_intersects(tc.geometry,pc.geom) = TRUE
                	  group by id_hex,id_comp,tc.geometry,pc.geom
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
                		tc.ciclo_calle as ciclo_calle,
                		st_intersection(tc.geometry,pc.geom) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geom) = TRUE
                ) as i_largo_ciclo
                where ciclo_calle = 1
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
                		st_intersection(tc.geometry,pc.geom) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geom) = TRUE
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
                		tc.\"proyect\" as proyect,
                		st_intersection(tc.geometry,pc.geom) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geom) = TRUE
                ) as i_p_1
                where proyect = 1
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
                		tc.\"proyect\" as proyect,
                		st_intersection(tc.geometry,pc.geom) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geom) = TRUE
                ) as i_p_2
                where proyect = 2
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
                   tc.\"o_op_ci\" as o_op_ci,
                   st_intersection(tc.geometry,pc.geom) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geom)= TRUE
                ) as i_op_0
                where o_op_ci = 0
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
                   tc.\"o_op_ci\" as o_op_ci,
                   st_intersection(tc.geometry,pc.geom) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geom)= TRUE
                ) as i_op_1
                where o_op_ci = 1
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
                   tc.\"o_op_cr\" as o_op_cr,
                   st_intersection(tc.geometry,pc.geom) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geom)= TRUE
                ) as i_cr_0
                where o_op_cr = 0
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
                   tc.\"o_op_cr\" as o_op_cr,
                   st_intersection(tc.geometry,pc.geom) as geometry
                  from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                  where st_intersects(tc.geometry,pc.geom)= TRUE
                ) as i_cr_1
                where o_op_cr = 1
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
                		tc.ciclo_calle as ciclo_calle,
                		st_intersection(tc.geometry,pc.geom) as geometry
                	from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                	where st_intersects(tc.geometry,pc.geom) = TRUE
                ) as i_largo_osm
                where ciclo_calle = 0
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
                        CICLOVIA_N,
                        sum(st_length(geometry)) as largo
                      from (
                    	  select 
                    	  	pc.id as id_hex,
                    	  	tc.\"ciclovia_n\" as CICLOVIA_N,
                    	  	tc.\"o_op_ci\" as o_op_ci,
                          st_intersection(tc.geometry,pc.geom) as geometry
                        from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                        where st_intersects(tc.geometry,pc.geom) = TRUE
                        group by id_hex,CICLOVIA_N,o_op_ci,tc.geometry,pc.geom
                      ) as inters
				            where CICLOVIA_N is not null and o_op_ci = 0
				            group by id_hex,CICLOVIA_N
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
                        CICLOVIA_N,
                        sum(st_length(geometry)) as largo
                      from (
                    	  select 
                    	  	pc.id as id_hex,
                    	  	tc.\"ciclovia_n\" as CICLOVIA_N,
                  	  	  tc.\"o_op_ci\" as o_op_ci,
                          st_intersection(tc.geometry,pc.geom) as geometry
                        from \"{x_schema}\".\"{x}\" tc, \"{h_schema}\".\"{h}\" pc
                        where st_intersects(tc.geometry,pc.geom) = TRUE
                        group by id_hex,CICLOVIA_N,o_op_ci,tc.geometry,pc.geom
                      ) as inters
				            where CICLOVIA_N is not null and o_op_ci = 1
				            group by id_hex,CICLOVIA_N
				            ) as ciclo_n
				            ) as ciclovian
				        where rnk = 1) as len_ci_n_m
                on pc.id = len_ci_n_m.id_hex"
              
             )
  )
  }
