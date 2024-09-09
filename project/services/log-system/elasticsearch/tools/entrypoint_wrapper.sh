#!/usr/bin/env bash

set -ex

# Get Secrets from Vault ------------------------------------------------------>
# mkdir -p /bitnami/elasticsearch/config/tls

curl -k -H "X-Vault-Token: $ELASTICSEARCH_VAULT_TOKEN" -X POST \
	-d '{"common_name": "elasticsearch.ft-transcendence.42", "ttl": "24h"}' \
	https://10.0.0.1:8200/v1/pki_int/issue/elasticsearch \
	-o /tmp/certs.json

jq -r '.data.certificate' /tmp/certs.json > /opt/bitnami/elasticsearch/config/elasticsearch.crt
jq -r '.data.private_key' /tmp/certs.json > /opt/bitnami/elasticsearch/config/elasticsearch.key
jq -r '.data.issuing_ca' /tmp/certs.json > /opt/bitnami/elasticsearch/config/ca.crt

rm -rf /tmp/certs.json

secrets=$(curl -k -H "X-Vault-Token: ${ELASTICSEARCH_VAULT_TOKEN}" \
		 -X GET https://10.0.0.1:8200/v1/secret/elasticsearch)

# Run EntryPoint -------------------------------------------------------------->
ELASTICSEARCH_PASSWORD=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_PASSWORD') \
ELASTICSEARCH_ENABLE_SECURITY=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_ENABLE_SECURITY') \
ELASTICSEARCH_ENABLE_REST_TLS=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_ENABLE_REST_TLS') \
ELASTICSEARCH_TLS_VERIFICATION_MODE=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_TLS_VERIFICATION_MODE') \
ELASTICSEARCH_HTTP_TLS_USE_PEM=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_USE_PEM') \
ELASTICSEARCH_HTTP_TLS_NODE_CERT_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_NODE_CERT_LOCATION') \
ELASTICSEARCH_HTTP_TLS_NODE_KEY_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_NODE_KEY_LOCATION') \
ELASTICSEARCH_HTTP_TLS_CA_CERT_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_CA_CERT_LOCATION') \
ELASTICSEARCH_SKIP_TRANSPORT_TLS=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_SKIP_TRANSPORT_TLS') \
/opt/bitnami/scripts/elasticsearch/entrypoint.sh /opt/bitnami/scripts/elasticsearch/run.sh
