source(file = here('src/graph_helpers.R'))
source(file = here("src/sql_helper.R"))
source(file = here('config.R'))

connec = test_database_conection(dsn_database,dsn_hostname,dsn_port,dsn_uid,dsn_pwd)

source(file = here('create_intermodal_network.R'))
source(file = here('cut_intermodal_network.R'))
source(file = here('calculate_component.r'))
source(file = here('to_h3.r'))