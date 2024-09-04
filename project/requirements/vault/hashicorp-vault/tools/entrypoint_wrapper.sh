#!/usr/bin/bash

# Run EntryPoint in background ------------------------------------------------>
vault server -config=/bitnami/vault/config/vault.json "$@" & 

# # Set Data Source ------------------------------------------------------------->
# source /entrypoint/set_data_source.sh

# # Set Dashboards -------------------------------------------------------------->
# source /entrypoint/set_dashboards.sh

# Wait for the main process to finish ----------------------------------------->
wait
