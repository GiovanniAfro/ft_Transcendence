#!/usr/bin/env bash

set -ex

secrets=$(curl -H "X-Vault-Token: ${LOG_SYSTEM_TOKEN}" \
		 -X GET http://10.0.4.1:8200/v1/secret/log-system)

unset LOG_SYSTEM_TOKEN

# Run EntryPoint -------------------------------------------------------------->
KIBANA_ELASTICSEARCH_URL=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_URL') \
KIBANA_HOST=$(echo "$secrets" | jq -r '.data.KIBANA_HOST') \
KIBANA_SERVER_ENABLE_TLS=$(echo "$secrets" | jq -r '.data.KIBANA_SERVER_ENABLE_TLS') \
KIBANA_CREATE_USER=$(echo "$secrets" | jq -r '.data.KIBANA_CREATE_USER') \
KIBANA_ELASTICSEARCH_PASSWORD=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_PASSWORD') \
KIBANA_PASSWORD=$(echo "$secrets" | jq -r '.data.KIBANA_PASSWORD') \
/opt/bitnami/scripts/kibana/entrypoint.sh /opt/bitnami/scripts/kibana/run.sh
