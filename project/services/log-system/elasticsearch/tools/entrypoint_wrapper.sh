#!/usr/bin/bash

set -e

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -s -k -H "X-Vault-Token: $ELASTICSEARCH_VAULT_TOKEN" -X POST -d '{
		"common_name": "elasticsearch.ft-transcendence.42",
		"ttl": "24h",
		"ip_sans": "10.0.2.1"
	}' https://10.0.0.1:8200/v1/pki_int/issue/elasticsearch)

echo "$certs" | jq -r '.data.certificate' > /opt/bitnami/elasticsearch/config/elasticsearch.crt
echo "$certs" | jq -r '.data.private_key' > /opt/bitnami/elasticsearch/config/elasticsearch.key
echo "$certs" | jq -r '.data.issuing_ca' > /opt/bitnami/elasticsearch/config/ca.crt

secrets=$(curl -s -k -H "X-Vault-Token: ${ELASTICSEARCH_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/elasticsearch)

# Run EntryPoint in Background ------------------------------------------------>
ELASTICSEARCH_PASSWORD=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_PASSWORD') \
ELASTICSEARCH_ENABLE_SECURITY=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_ENABLE_SECURITY') \
ELASTICSEARCH_ENABLE_REST_TLS=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_ENABLE_REST_TLS') \
ELASTICSEARCH_TLS_VERIFICATION_MODE=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_TLS_VERIFICATION_MODE') \
ELASTICSEARCH_HTTP_TLS_USE_PEM=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_USE_PEM') \
ELASTICSEARCH_HTTP_TLS_NODE_CERT_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_NODE_CERT_LOCATION') \
ELASTICSEARCH_HTTP_TLS_NODE_KEY_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_NODE_KEY_LOCATION') \
ELASTICSEARCH_HTTP_TLS_CA_CERT_LOCATION=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_HTTP_TLS_CA_CERT_LOCATION') \
ELASTICSEARCH_SKIP_TRANSPORT_TLS=$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_SKIP_TRANSPORT_TLS') \
/opt/bitnami/scripts/elasticsearch/entrypoint.sh /opt/bitnami/scripts/elasticsearch/run.sh &

# Wait for Elasticsearch ------------------------------------------------------>
while ! curl -k -o /dev/null -s -H --fail https://10.0.2.1:9200; do
	echo "waiting for elasticsearch ..."
	sleep 1
done

# Create ILM Policy ----------------------------------------------------------->
curl -k -X PUT 'https://10.0.2.1:9200/_ilm/policy/ft-transcendence-policy' \
     -u elastic:$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_PASSWORD') \
     -H 'Content-Type: application/json' \
     -d '{
			"policy": {
				"_meta": {
					"description": "used for ft-transcendence logs",
					"project": {
						"name": "ft-transcendence"
					}
				},
				"phases": {
					"hot": {
						"min_age": "0ms",
						"actions": {
							"set_priority": {
								"priority": 100
							}
						}
					},
					"delete": {
						"min_age": "1h",
						"actions": {
							"delete": {
								"delete_searchable_snapshot": true
							}
						}
					}
				}
			}
		}'

# Create a Index Template ----------------------------------------------------->
curl -k -X PUT "https://10.0.2.1:9200/_index_template/ft-transcendence-logs?pretty" \
     -u elastic:$(echo "$secrets" | jq -r '.data.ELASTICSEARCH_PASSWORD') \
     -H 'Content-Type: application/json' \
     -d '{
			"index_patterns": [
				"logs-*-*"
			],
			"template": {
				"settings": {
					"index": {
						"lifecycle": {
							"name": "ft-transcendence-policy"
						}
					}
				}
			},
			"composed_of": [
				"logs@mappings",
				"logs@settings",
				"ecs@mappings"
			],
			"priority": 100000,
			"data_stream": {
				"hidden": false,
				"allow_custom_routing": false
			},
			"allow_auto_create": true
	 	}'

# Wait for the Main Process --------------------------------------------------->
wait
