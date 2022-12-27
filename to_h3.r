
source(file = here("src/sql_helper.r"))
source(file = here("config.r"))
source(file = here("src/h3_helpers.r"))

for (setting in settings_list) {
  to_h3(
    h_schema = H_SCHEMA,
    h = HEX_NAME,
    x_schema = 'public',
    x = setting$nombre_resultado,
    connec = connec)
}