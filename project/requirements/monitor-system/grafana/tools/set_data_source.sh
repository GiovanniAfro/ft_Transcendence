#!/usr/bin/bash

set -e

curl -X POST \
	 -H "Content-Type: application/json" \
	 -d '{
		"name": "Prometheus",
		"type": "prometheus",
		"url": "http://10.0.3.1:9090",
		"access": "proxy",
		"isDefault": true
	 }' \
	 http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@127.0.0.1:3000/api/datasources
