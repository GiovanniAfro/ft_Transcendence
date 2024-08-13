#!/usr/bin/bash

set -e

POSTGRES_DASHBOARD=$(cat "/var/lib/grafana/dashboards/postgres-dashboard.json")

curl -X POST http://127.0.0.1:3000/api/dashboards/db \
     -H "Content-Type: application/json" \
     -u grafana:grafanapwd \
     -d @- <<EOF
     {
     "dashboard": $POSTGRES_DASHBOARD
     }
     EOF
