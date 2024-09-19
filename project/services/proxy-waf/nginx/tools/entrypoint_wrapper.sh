#!/usr/bin/bash

set -ex

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -k -H "X-Vault-Token: $NGINX_VAULT_TOKEN" -X POST -d '{
		"common_name": "ft-transcendence.42",
		"ip_sans": "10.0.4.1",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/nginx)

echo "$certs" | jq -r '.data.certificate' \
	> /certs/nginx.crt
echo "$certs" | jq -r '.data.private_key' \
	> /certs/nginx.key
echo "$certs" | jq -r '.data.issuing_ca' \
	> /certs/ca.crt
echo "$certs" | jq -r '.data.ca_chain[]' \
	> /certs/ca_chain.crt

# env=$(curl -k -H "X-Vault-Token: ${NGINX_VAULT_TOKEN}" \
# 	-X GET https://10.0.0.1:8200/v1/secret/nginx)

# export POSTGRESQL_USERNAME=$(echo "$env" | jq -r '.data.POSTGRESQL_USERNAME')
# export POSTGRESQL_PASSWORD=$(echo "$env" | jq -r '.data.POSTGRESQL_PASSWORD')
# export POSTGRESQL_DATABASE=$(echo "$env" | jq -r '.data.POSTGRESQL_DATABASE')
# export POSTGRESQL_ENABLE_TLS=$(echo "$env" | jq -r '.data.POSTGRESQL_ENABLE_TLS')
# export POSTGRESQL_TLS_CERT_FILE=$(echo "$env" | jq -r '.data.POSTGRESQL_TLS_CERT_FILE')
# export POSTGRESQL_TLS_KEY_FILE=$(echo "$env" | jq -r '.data.POSTGRESQL_TLS_KEY_FILE')
# export POSTGRESQL_TLS_CA_FILE=$(echo "$env" | jq -r '.data.POSTGRESQL_TLS_CA_FILE')
# export POSTGRESQL_PGHBA_FILE=$(echo "$env" | jq -r '.data.POSTGRESQL_PGHBA_FILE')

# Run EntryPoint -------------------------------------------------------------->
exec /opt/bitnami/scripts/nginx/entrypoint.sh "$@" &


# Wait for the Main Process --------------------------------------------------->
wait
