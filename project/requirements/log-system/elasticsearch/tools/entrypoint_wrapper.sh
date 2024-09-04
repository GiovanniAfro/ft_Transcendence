#!/usr/bin/env bash

set -e

secrets=$(curl -H "X-Vault-Token: ${LOG_SYSTEM_TOKEN}" \
		 -X GET http://10.0.4.1:8200/v1/secret/log-system)

unset LOG_SYSTEM_TOKEN

# Run EntryPoint -------------------------------------------------------------->
ELASTICSEARCH_PASSWORD=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_PASSWORD') \
ELASTICSEARCH_ENABLE_SECURITY=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_ENABLE_SECURITY') \
/opt/bitnami/scripts/elasticsearch/entrypoint.sh /opt/bitnami/scripts/elasticsearch/run.sh
