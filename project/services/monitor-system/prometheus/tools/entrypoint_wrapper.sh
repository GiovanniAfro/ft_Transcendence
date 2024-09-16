#!/usr/bin/bash

set -ex

# Get Certs from Vault -------------------------------------------------------->
certs=$(curl -s -k -H "X-Vault-Token: $PROMETHEUS_VAULT_TOKEN" -X POST -d '{
		"common_name": "prometheus.ft-transcendence.42",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/prometheus)

echo "$certs" | jq -r '.data.certificate' > /opt/bitnami/prometheus/conf/prometheus.crt
echo "$certs" | jq -r '.data.private_key' > /opt/bitnami/prometheus/conf/prometheus.key
echo "$certs" | jq -r '.data.issuing_ca' > /opt/bitnami/prometheus/conf/ca.crt

# Write Token to file --------------------------------------------------------->

echo $PROMETHEUS_VAULT_TOKEN > /opt/bitnami/prometheus/conf/vault-token

# Run EntryPoint -------------------------------------------------------------->
/opt/bitnami/prometheus/bin/prometheus \
	--config.file=/opt/bitnami/prometheus/conf/prometheus.yml \
	--web.config.file=/opt/bitnami/prometheus/conf/web.yml \
	--web.console.libraries=/opt/bitnami/prometheus/conf/console_libraries \
	--web.console.templates=/opt/bitnami/prometheus/conf/consoles \
	--storage.tsdb.path=/opt/bitnami/prometheus/data \
	--storage.tsdb.retention.time=30d
