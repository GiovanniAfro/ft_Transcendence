#!/usr/bin/env bash

set -e

secrets=$(curl -k -H "X-Vault-Token: ${APP_TOKEN}" \
		 -X GET https://10.0.0.1:8200/v1/secret/app)

# Run EntryPoint -------------------------------------------------------------->
POSTGRESQL_DATABASE=$(echo "$secrets" | jq -r '.data.POSTGRESQL_DATABASE') \
POSTGRESQL_USERNAME=$(echo "$secrets" | jq -r '.data.POSTGRESQL_USERNAME') \
POSTGRESQL_PASSWORD=$(echo "$secrets" | jq -r '.data.POSTGRESQL_PASSWORD') \
/opt/bitnami/scripts/postgresql/entrypoint.sh /opt/bitnami/scripts/postgresql/run.sh
