#!/usr/bin/bash

set -ex

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -k -H "X-Vault-Token: $NGINX_VAULT_TOKEN" -X POST -d '{
		"common_name": "ft-transcendence.42",
		"ip_sans": "10.0.4.1",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/nginx)

echo "$certs" | jq -r '.data.certificate' \
	> /tmp/nginx.crt
echo "$certs" | jq -r '.data.private_key' \
	> /tmp/nginx.key
echo "$certs" | jq -r '.data.issuing_ca' \
	> /tmp/ca.crt
echo "$certs" | jq -r '.data.ca_chain[]' \
	> /tmp/ca_chain.crt

# env=$(curl -k -H "X-Vault-Token: ${NGINX_VAULT_TOKEN}" \
# 	-X GET https://10.0.0.1:8200/v1/secret/nginx)

# export PORT=$(echo "$env" | jq -r '.data.PORT')
# export NGINX_ALWAYS_TLS_REDIRECT=$(echo "$env" | jq -r '.data.NGINX_ALWAYS_TLS_REDIRECT')
# export SSL_PORT=$(echo "$env" | jq -r '.data.SSL_PORT')
# export SERVER_NAME=$(echo "$env" | jq -r '.data.SERVER_NAME')
# export SSL_CERT=$(echo "$env" | jq -r '.data.SSL_CERT')
# export SSL_CERT_KEY=$(echo "$env" | jq -r '.data.SSL_CERT_KEY')
# export SSL_PROTOCOLS=$(echo "$env" | jq -r '.data.SSL_PROTOCOLS')
# export SSL_CIPHERS=$(echo "$env" | jq -r '.data.SSL_CIPHERS')
# export SSL_PREFER_CIPHERS=$(echo "$env" | jq -r '.data.SSL_PREFER_CIPHERS')
# export SSL_VERIFY=$(echo "$env" | jq -r '.data.SSL_VERIFY')
# export BACKEND=$(echo "$env" | jq -r '.data.BACKEND')
# export REAL_IP_HEADER=$(echo "$env" | jq -r '.data.REAL_IP_HEADER')
# export REAL_IP_PROXY_HEADER=$(echo "$env" | jq -r '.data.REAL_IP_PROXY_HEADER')
# export REAL_IP_RECURSIVE=$(echo "$env" | jq -r '.data.REAL_IP_RECURSIVE')
# export METRICS_ALLOW_FROM=$(echo "$env" | jq -r '.data.METRICS_ALLOW_FROM')

# Remove defaults ------------------------------------------------------------->
# rm -rf /etc/nginx/conf.d/default.conf

# Run EntryPoint -------------------------------------------------------------->
nginx -g 'daemon off;'
