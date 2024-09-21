#!/usr/bin/bash

set -e

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -k -H "X-Vault-Token: $POSTGRESQL_VAULT_TOKEN" -X POST -d '{
		"common_name": "postgresql.ft-transcendence.42",
		"ip_sans": "10.0.1.2",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/postgresql)

echo "$certs" | jq -r '.data.certificate' \
	> /opt/bitnami/postgresql/conf/postgresql.crt
echo "$certs" | jq -r '.data.private_key' \
	> /opt/bitnami/postgresql/conf/postgresql.key
echo "$certs" | jq -r '.data.issuing_ca' \
	> /opt/bitnami/postgresql/conf/ca.crt
echo "$certs" | jq -r '.data.ca_chain[]' \
	> /opt/bitnami/postgresql/conf/ca_chain.crt

env=$(curl -k -H "X-Vault-Token: ${POSTGRESQL_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/postgresql)

export POSTGRESQL_USERNAME=$(echo "$env" | jq -r '.data.POSTGRESQL_USERNAME')
export POSTGRESQL_PASSWORD=$(echo "$env" | jq -r '.data.POSTGRESQL_PASSWORD')
export POSTGRESQL_DATABASE=$(echo "$env" | jq -r '.data.POSTGRESQL_DATABASE')
export POSTGRESQL_ENABLE_TLS=$(echo "$env" | jq -r '.data.POSTGRESQL_ENABLE_TLS')
export POSTGRESQL_TLS_CERT_FILE=$(echo "$env" | jq -r '.data.POSTGRESQL_TLS_CERT_FILE')
export POSTGRESQL_TLS_KEY_FILE=$(echo "$env" | jq -r '.data.POSTGRESQL_TLS_KEY_FILE')
export POSTGRESQL_TLS_CA_FILE=$(echo "$env" | jq -r '.data.POSTGRESQL_TLS_CA_FILE')
export POSTGRESQL_EXTRA_FLAGS=$(echo "$env" | jq -r '.data.POSTGRESQL_EXTRA_FLAGS')

# Run EntryPoint -------------------------------------------------------------->
exec /opt/bitnami/scripts/postgresql/entrypoint.sh "$@" &

# Wait for the Main Process --------------------------------------------------->
wait
