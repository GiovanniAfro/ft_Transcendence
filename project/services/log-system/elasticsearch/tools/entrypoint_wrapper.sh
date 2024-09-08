#!/usr/bin/env bash

set -e

secrets=$(curl -H "X-Vault-Token: ${LOG_SYSTEM_TOKEN}" \
		 -X GET http://10.0.4.1:8200/v1/secret/log-system)

unset LOG_SYSTEM_TOKEN

# Run EntryPoint -------------------------------------------------------------->
# ELASTICSEARCH_ENABLE_SECURITY=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_ENABLE_SECURITY') \
# ELASTICSEARCH_KEYSTORE_PASSWORD=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_KEYSTORE_PASSWORD') \
# ELASTICSEARCH_TRUSTSTORE_PASSWORD=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_TRUSTSTORE_PASSWORD') \
# ELASTICSEARCH_KEYSTORE_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_KEYSTORE_LOCATION') \
# ELASTICSEARCH_TRUSTSTORE_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_TRUSTSTORE_LOCATION') \
ELASTICSEARCH_PASSWORD=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_PASSWORD') \
/opt/bitnami/scripts/elasticsearch/entrypoint.sh /opt/bitnami/scripts/elasticsearch/run.sh
