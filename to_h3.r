
source(file = here("src/sql_helper.R"))
source(file = here("config.R"))
source(file = here("src/h3_helpers.R"))

for (setting in setting_list) {
  to_h3(
    h_schema = H_SCHEMA,
    h = HEX_NAME,
    x_schema = 'public',
    x = setting$nombre_resultado)
}