#!/usr/bin/bash

set -ex

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -s -k -H "X-Vault-Token: $GRAFANA_VAULT_TOKEN" -X POST -d '{
		"common_name": "grafana.ft-transcendence.42",
		"ttl": "24h",
		"ip_sans": "10.0.3.2"
	}' https://10.0.0.1:8200/v1/pki_int/issue/grafana)

echo "$certs" | jq -r '.data.certificate' > /opt/bitnami/grafana/conf/grafana.crt
echo "$certs" | jq -r '.data.private_key' > /opt/bitnami/grafana/conf/grafana.key
echo "$certs" | jq -r '.data.issuing_ca' > /opt/bitnami/grafana/conf/ca.crt

secrets=$(curl -s -k -H "X-Vault-Token: ${GRAFANA_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/grafana)

# Run EntryPoint in Background ------------------------------------------------>
GF_SECURITY_ADMIN_USER=$(echo "$secrets" | jq -r '.data.GF_SECURITY_ADMIN_USER') \
GF_SECURITY_ADMIN_PASSWORD=$(echo "$secrets" | jq -r '.data.GF_SECURITY_ADMIN_PASSWORD') \
/opt/bitnami/scripts/grafana/entrypoint.sh /opt/bitnami/scripts/grafana/run.sh &

# Wait for Grafana ------------------------------------------------------------>
while ! curl -k -o /dev/null -s -H --fail https://10.0.3.2:3000; do
	echo "waiting for grafana ..."
	sleep 1
done

# Set Data Source ------------------------------------------------------------->
auth="$(echo "$secrets" | jq -r '.data.GF_SECURITY_ADMIN_USER'):$(echo "$secrets" | jq -r '.data.GF_SECURITY_ADMIN_PASSWORD')"

curl -k -X POST \
	 -H "Content-Type: application/json" \
	 -d '{
		"name": "Prometheus",
		"type": "prometheus",
		"url": "https://10.0.3.1:9090",
		"access": "proxy",
		"isDefault": true,
		"basicAuth": true,
		"basicAuthUser": "prometheus",
		"secureJsonData": {
			"basicAuthPassword": "test",
			"tlsCACert": "'"$(echo "$certs" | jq -r '.data.issuing_ca' | tr -d '\n')"'",
			"tlsClientCert": "'"$(echo "$certs" | jq -r '.data.certificate' | tr -d '\n')"'",
			"tlsClientKey": "'"$(echo "$certs" | jq -r '.data.private_key' | tr -d '\n')"'"
		}
	 }' \
	 https://$auth@10.0.3.2:3000/api/datasources

# Import Dashboards ----------------------------------------------------------->
# dashboard_path="/opt/bitnami/grafana/conf/provisioning/dashboards/"
# endpoint="https://10.0.3.2:3000/api/dashboards/db"

# for FILE in "$dashboard_path"/*.json; do
#      dashboard_json=$(cat "$FILE")
#     #  filename=$(basename "$FILE" .json)

#      curl -k -X POST "$endpoint" \
#           -H "Content-Type: application/json" \
#           -u "$auth" \
#           -d "{\"dashboard\": $dashboard_json, \"overwrite\": true}"
#      sleep 1
# done

# Wait for the Main Process --------------------------------------------------->
wait
