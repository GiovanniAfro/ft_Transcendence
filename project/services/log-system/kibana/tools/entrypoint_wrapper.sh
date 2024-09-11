#!/usr/bin/bash

set -e

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -s -k -H "X-Vault-Token: $KIBANA_VAULT_TOKEN" -X POST -d '{
        "common_name": "kibana.ft-transcendence.42",
        "ttl": "24h",
        "ip_sans": "10.0.2.3"
    }' https://10.0.0.1:8200/v1/pki_int/issue/kibana)

echo "$certs" | jq -r '.data.certificate' > /opt/bitnami/kibana/config/kibana.crt
echo "$certs" | jq -r '.data.private_key' > /opt/bitnami/kibana/config/kibana.key
echo "$certs" | jq -r '.data.issuing_ca' > /opt/bitnami/kibana/config/ca.crt

secrets=$(curl -s -k -H "X-Vault-Token: $KIBANA_VAULT_TOKEN" \
	-X GET https://10.0.0.1:8200/v1/secret/kibana)

# Run EntryPoint in Background ------------------------------------------------>
KIBANA_PASSWORD=$(echo "$secrets" | jq -r '.data.KIBANA_PASSWORD') \
KIBANA_HOST=$(echo "$secrets" | jq -r '.data.KIBANA_HOST') \
KIBANA_CREATE_USER=$(echo "$secrets" | jq -r '.data.KIBANA_CREATE_USER') \
KIBANA_CERTS_DIR=$(echo "$secrets" | jq -r '.data.KIBANA_CERTS_DIR') \
KIBANA_SERVER_ENABLE_TLS=$(echo "$secrets" | jq -r '.data.KIBANA_SERVER_ENABLE_TLS') \
KIBANA_SERVER_TLS_USE_PEM=$(echo "$secrets" | jq -r '.data.KIBANA_SERVER_TLS_USE_PEM') \
KIBANA_SERVER_CERT_LOCATION=$(echo "$secrets" | jq -r '.data.KIBANA_SERVER_CERT_LOCATION') \
KIBANA_SERVER_KEY_LOCATION=$(echo "$secrets" | jq -r '.data.KIBANA_SERVER_KEY_LOCATION') \
KIBANA_ELASTICSEARCH_URL=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_URL') \
KIBANA_ELASTICSEARCH_PASSWORD=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_PASSWORD') \
KIBANA_ELASTICSEARCH_ENABLE_TLS=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_ENABLE_TLS') \
KIBANA_ELASTICSEARCH_TLS_VERIFICATION_MODE=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_TLS_VERIFICATION_MODE') \
KIBANA_ELASTICSEARCH_TLS_USE_PEM=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_TLS_USE_PEM') \
KIBANA_ELASTICSEARCH_CA_CERT_LOCATION=$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_CA_CERT_LOCATION') \
/opt/bitnami/scripts/kibana/entrypoint.sh /opt/bitnami/scripts/kibana/run.sh &

# Wait for Kibana ------------------------------------------------------------->
while ! curl -k -o /dev/null -s -H --fail https://10.0.2.3:5601; do
	echo "waiting for kibana ..."
	sleep 1
done

sleep 60

# Create a DataView ----------------------------------------------------------->
curl -k -X POST https://10.0.2.3:5601/api/data_views/data_view \
	-u elastic:$(echo "$secrets" | jq -r '.data.KIBANA_ELASTICSEARCH_PASSWORD')\
	-H "Content-Type: application/json;" \
	-H "kbn-xsrf: true" \
	-d '{
		"data_view": {
			"name": "ft-transcendence",
			"title": "logstash-*",
			"timeFieldName": "@timestamp"
		}
	}'

# Wait for the Main Process --------------------------------------------------->
wait
