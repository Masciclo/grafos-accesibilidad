##Forzar instalación de librería here
packages <- c("here")
install.packages(setdiff(packages,rownames(installed.packages())))
library(here)

#Cargar funciones asociadas a SQL
source(file = here("src/sql_helper.r"))
#Cargar configuración
source(file = here('config.r'))

#Crear la red intermodal
source(file = here('create_intermodal_network.r'))
#Cortar la red intermodal
source(file = here('cut_intermodal_network.r'))
#Calculo de componentes
source(file = here('calculate_component.r'))
#Resultados en H3 
source(file = here('to_h3.r'))

#Eliminar reulstados en H3
for (setting in settings_list) {
  delete_h3_results(h = HEX_NAME,
                    nombre_escenario = setting$nombre_resultado,
                    connec = connec)
}

