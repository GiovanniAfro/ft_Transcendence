#!/usr/bin/bash

set -ex

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -s -k -H "X-Vault-Token: $NGINX_EXPORTER_VAULT_TOKEN" -X POST -d '{
		"common_name": "nginx-exporter.ft-transcendence.42",
		"ip_sans": "10.0.3.3",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/nginx-exporter)

# mkdir -p /opt/bitnami/nginx-exporter/tls
# chown -R 

# echo "$certs" | jq -r '.data.certificate' > /opt/bitnami/nginx-exporter/tls/nginx-exporter.crt
# echo "$certs" | jq -r '.data.private_key' > /opt/bitnami/nginx-exporter/tls/nginx-exporter.key
# echo "$certs" | jq -r '.data.issuing_ca' > /opt/bitnami/nginx-exporter/tls/ca.crt

env=$(curl -s -k -H "X-Vault-Token: ${NGINX_EXPORTER_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/nginx-exporter)

# Run EntryPoint in Background ------------------------------------------------>
DATA_SOURCE_URI=$(echo "$env" | jq -r '.data.DATA_SOURCE_URI') \
nginx-prometheus-exporter &

# Wait for the Main Process --------------------------------------------------->
wait
