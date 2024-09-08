#!/usr/bin/env bash

set -ex

secrets=$(curl -H "X-Vault-Token: ${LOG_SYSTEM_TOKEN}" \
		 -X GET http://10.0.4.1:8200/v1/secret/log-system)

unset LOG_SYSTEM_TOKEN

# Run EntryPoint -------------------------------------------------------------->
LOGSTASH_ENABLE_GELF_INPUT=$(echo "$secrets" | jq -r '.data.LOGSTASH_ENABLE_GELF_INPUT') \
LOGSTASH_ENABLE_HTTP_INPUT=$(echo "$secrets" | jq -r '.data.LOGSTASH_ENABLE_HTTP_INPUT') \
LOGSTASH_GELF_PORT_NUMBER=$(echo "$secrets" | jq -r '.data.LOGSTASH_GELF_PORT_NUMBER') \
LOGSTASH_ENABLE_ELASTICSEARCH_OUTPUT=$(echo "$secrets" | jq -r '.data.LOGSTASH_ENABLE_ELASTICSEARCH_OUTPUT') \
/opt/bitnami/scripts/logstash/entrypoint.sh /opt/bitnami/scripts/logstash/run.sh
