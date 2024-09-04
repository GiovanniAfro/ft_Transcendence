#!/usr/bin/env bash

set -eu

source "${BASH_SOURCE[0]%/*}"/lib.sh

# Check if flag exists -------------------------------------------------------->

check_flag() {
	[[ -f "/usr/share/elasticsearch/data/flag_file" ]]
}

if check_flag; then
    log "Flag file exists. Exiting script."
    exit 0
else
	log "Flag does not exists"
fi

sleep 5

# Waiting for availability of Elasticsearch ----------------------------------->

log "Waiting for availability of Elasticsearch. This can take several minutes."

declare -i exit_code=0
wait_for_elasticsearch || exit_code=$?

if ((exit_code)); then
	case $exit_code in
		6)
			suberr "Could not resolve host. Is Elasticsearch running?"
			;;
		7)
			suberr "Failed to connect to host. Is Elasticsearch healthy?"
			;;
		28)
			suberr "Timeout connecting to host. Is Elasticsearch healthy?"
			;;
		*)
			suberr "Connection to Elasticsearch failed. Exit code: ${exit_code}"
			;;
	esac

	exit $exit_code
fi

sublog "Elasticsearch is running"

# Set Users and Roles --------------------------------------------------------->

source /tmp/set_users.sh

# Set Data Retention Policy --------------------------------------------------->

source /tmp/set_data_retention_policy.sh

# Create Flag ----------------------------------------------------------------->

touch "/usr/share/elasticsearch/data/flag_file"
