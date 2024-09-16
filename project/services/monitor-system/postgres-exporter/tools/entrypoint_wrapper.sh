#!/usr/bin/bash

set -ex

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -k -H "X-Vault-Token: $POSTGRES_EXPORTER_VAULT_TOKEN" -X POST -d '{
		"common_name": "postgres-exporter.ft-transcendence.42",
		"ip_sans": "10.0.3.4",
		"uri_sans": "postgres-exporter",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/postgres-exporter)

echo "$certs" | jq -r '.data.certificate' \
	> /opt/bitnami/postgres-exporter/tls/postgres-exporter.crt
echo "$certs" | jq -r '.data.private_key' \
	> /opt/bitnami/postgres-exporter/tls/postgres-exporter.key
echo "$certs" | jq -r '.data.issuing_ca' \
	> /opt/bitnami/postgres-exporter/tls/ca.crt

echo "$certs" | jq -r '.data.ca_chain[]' \
	> /opt/bitnami/postgres-exporter/tls/ca_chain.crt


chmod 600 /opt/bitnami/postgres-exporter/tls/postgres-exporter.key

env=$(curl -k -H "X-Vault-Token: ${POSTGRES_EXPORTER_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/postgres-exporter)

# Run EntryPoint -------------------------------------------------------------->
DATA_SOURCE_URI=$(echo "$env" | jq -r '.data.DATA_SOURCE_URI') \
DATA_SOURCE_USER=$(echo "$env" | jq -r '.data.DATA_SOURCE_USER') \
DATA_SOURCE_PASS=$(echo "$env" | jq -r '.data.DATA_SOURCE_PASS') \
postgres_exporter --web.config.file=/opt/bitnami/postgres-exporter/web_config.yml
