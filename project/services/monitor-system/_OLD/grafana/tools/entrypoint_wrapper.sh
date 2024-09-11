#!/usr/bin/bash

# Run EntryPoint in background ------------------------------------------------>
/run.sh "$@" & # /run.sh is default entrypoint of pre-built image 

# Wait for Grafana ------------------------------------------------------------>
while true; do
	HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:3000/login")
  	if [ "$HTTP_CODE" -eq 200 ]; then
    	echo "Grafana is running"
    	break
  	else
    	echo "Connection to Grafana failed. Exit code: $HTTP_CODE"
    	sleep 1
  	fi
done

# Set Data Source ------------------------------------------------------------->
source /entrypoint/set_data_source.sh

# Set Dashboards -------------------------------------------------------------->
source /entrypoint/set_dashboards.sh

# Wait for the main process to finish ----------------------------------------->
wait
