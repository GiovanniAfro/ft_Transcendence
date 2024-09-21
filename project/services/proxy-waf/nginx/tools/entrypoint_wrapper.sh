#!/usr/bin/bash

set -ex

# Get Certs from Vault -------------------------------------------------------->
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

# Run EntryPoint -------------------------------------------------------------->
exec nginx -g 'daemon off;'
