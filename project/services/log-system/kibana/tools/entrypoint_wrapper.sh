#!/usr/bin/env bash

set -ex

# Get Secrets from Vault ------------------------------------------------------>
mkdir -p /bitnami/kibana/tls

curl -k -H "X-Vault-Token: $KIBANA_VAULT_TOKEN" -X POST -d '{
		"common_name": "kibana.ft-transcendence.42",
		"ttl": "24h",
		"ip_sans": "10.0.2.3"
	}' \
	https://10.0.0.1:8200/v1/pki_int/issue/kibana \
	-o /tmp/certs.json

jq -r '.data.certificate' /tmp/certs.json > /opt/bitnami/kibana/config/kibana.crt
jq -r '.data.private_key' /tmp/certs.json > /opt/bitnami/kibana/config/kibana.key
jq -r '.data.issuing_ca' /tmp/certs.json > /opt/bitnami/kibana/config/ca.crt

secrets=$(curl -k -H "X-Vault-Token: $KIBANA_VAULT_TOKEN" \
		 -X GET https://10.0.0.1:8200/v1/secret/kibana \
		 -o /tmp/secrets.json)

cat /tmp/secrets.json

kibana_password=$(jq -r '.data.KIBANA_PASSWORD' /tmp/secrets.json)
kibana_host=$(jq -r '.data.KIBANA_HOST' /tmp/secrets.json)
kibana_create_user=$(jq -r '.data.KIBANA_CREATE_USER' /tmp/secrets.json)
kibana_server_enable_tls=$(jq -r '.data.KIBANA_SERVER_ENABLE_TLS' /tmp/secrets.json)
kibana_elasticsearch_url=$(jq -r '.data.KIBANA_ELASTICSEARCH_URL' /tmp/secrets.json)
kibana_elasticsearch_password=$(jq -r '.data.KIBANA_ELASTICSEARCH_PASSWORD' /tmp/secrets.json)
kibana_elasticsearch_enable_tls=$(jq -r '.data.KIBANA_ELASTICSEARCH_ENABLE_TLS' /tmp/secrets.json)
kibana_elasticsearch_tls_verification_mode=$(jq -r '.data.KIBANA_ELASTICSEARCH_TLS_VERIFICATION_MODE' /tmp/secrets.json)
kibana_elasticsearch_tls_use_pem=$(jq -r '.data.KIBANA_ELASTICSEARCH_TLS_USE_PEM' /tmp/secrets.json)
kibana_elasticsearch_ca_cert_location=$(jq -r '.data.KIBANA_ELASTICSEARCH_CA_CERT_LOCATION' /tmp/secrets.json)

# rm -rf /tmp/secrets.json && rm -rf /tmp/certs.json

# Run EntryPoint -------------------------------------------------------------->
KIBANA_PASSWORD=$kibana_password \
KIBANA_HOST=$kibana_host \
KIBANA_CREATE_USER=$kibana_create_user \
KIBANA_CERTS_DIR=$(jq -r '.data.KIBANA_CERTS_DIR' /tmp/secrets.json) \
KIBANA_SERVER_ENABLE_TLS=$kibana_server_enable_tls \
KIBANA_SERVER_TLS_USE_PEM=$(jq -r '.data.KIBANA_SERVER_TLS_USE_PEM' /tmp/secrets.json) \
KIBANA_SERVER_CERT_LOCATION=$(jq -r '.data.KIBANA_SERVER_CERT_LOCATION' /tmp/secrets.json) \
KIBANA_SERVER_KEY_LOCATION=$(jq -r '.data.KIBANA_SERVER_KEY_LOCATION' /tmp/secrets.json) \
KIBANA_ELASTICSEARCH_URL=$kibana_elasticsearch_url \
KIBANA_ELASTICSEARCH_PASSWORD=$kibana_elasticsearch_password \
KIBANA_ELASTICSEARCH_ENABLE_TLS=$kibana_elasticsearch_enable_tls \
KIBANA_ELASTICSEARCH_TLS_VERIFICATION_MODE=$kibana_elasticsearch_tls_verification_mode \
KIBANA_ELASTICSEARCH_TLS_USE_PEM=$kibana_elasticsearch_tls_use_pem \
KIBANA_ELASTICSEARCH_CA_CERT_LOCATION=$kibana_elasticsearch_ca_cert_location \
/opt/bitnami/scripts/kibana/entrypoint.sh /opt/bitnami/scripts/kibana/run.sh
