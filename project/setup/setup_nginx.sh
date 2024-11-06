#!/bin/bash

# Get Token ------------------------------------------------------------------->
token=$(grep '^NGINX_VAULT_TOKEN=' .env | cut -d'=' -f2)

# Get TLS Certificates from Vault --------------------------------------------->
mkdir -p setup/.tmp/tls/certs
mkdir -p setup/.tmp/tls/private

certs=$(curl -s -k -H "X-Vault-Token: ${token}" -X POST -d '{
		"common_name": "ft-transcendence.42",
		"ip_sans": "10.0.4.1",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/nginx)

cleaned_certs=$(echo "$certs" | tr -cd '\11\12\15\40-\176')
echo "$cleaned_certs" | jq -r '.data.certificate' > setup/.tmp/tls/certs/nginx.crt
echo "$cleaned_certs" | jq -r '.data.private_key' > setup/.tmp/tls/private/nginx.key
echo "$cleaned_certs" | jq -r '.data.issuing_ca' > setup/.tmp/tls/certs/ca.crt
echo "$cleaned_certs" | jq -r '.data.ca_chain[]' > setup/.tmp/tls/certs/ca_chain.crt

chmod 400 setup/.tmp/tls/private/nginx.key

# Get Envs from Vault --------------------------------------------------------->
envs=$(curl -s -k -H "X-Vault-Token: $token" \
    -X GET https://10.0.0.1:8200/v1/secret/nginx)

echo "PORT=$(echo "$envs" | jq -r '.data.PORT')" >> .env
echo "SERVER_NAME=$(echo "$envs" | jq -r '.data.SERVER_NAME')" >> .env
echo "NGINX_ALWAYS_TLS_REDIRECT=$(echo "$envs" | jq -r '.data.NGINX_ALWAYS_TLS_REDIRECT')" >> .env
echo "BACKEND=$(echo "$envs" | jq -r '.data.BACKEND')" >> .env
echo "SSL_PORT=$(echo "$envs" | jq -r '.data.SSL_PORT')" >> .env
echo "PROXY_SSL_CERT=$(echo "$envs" | jq -r '.data.PROXY_SSL_CERT')" >> .env
echo "PROXY_SSL_CERT_KEY=$(echo "$envs" | jq -r '.data.PROXY_SSL_CERT_KEY')" >> .env
echo "PROXY_SSL_PROTOCOLS=$(echo "$envs" | jq -r '.data.PROXY_SSL_PROTOCOLS')" >> .env
echo "PROXY_SSL_CIPHERS=$(echo "$envs" | jq -r '.data.PROXY_SSL_CIPHERS')" >> .env
echo "PROXY_SSL_PREFER_CIPHERS=$(echo "$envs" | jq -r '.data.PROXY_SSL_PREFER_CIPHERS')" >> .env
echo "ALLOWED_METHODS=$(echo "$envs" | jq -r '.data.ALLOWED_METHODS')" >> .env

# Create Nginx Container ------------------------------------------------------>
docker compose -p "ft_transcendence" --profile proxy-waf up -d
