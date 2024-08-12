#!/usr/bin/bash

set -e

curl -X POST http://127.0.0.1:3000/api/dashboards/import \
     -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
     -H "Content-Type: application/json" \
	 -d "{\"dashboard\":$(cat /usr/local/grafana/conf/9628_rev7.json)}"
