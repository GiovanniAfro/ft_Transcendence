#!/usr/bin/bash

set -e

# DASHBOARDS_PATH="/var/lib/grafana/dashboards/"

# for FILE in "$DASHBOARDS_PATH"/*; do
#      if [ -f "$FILE" ]; then
#           DASHBOARD=$(<"$FILE")
#           TEMP_FILE=$(mktemp)

#           echo "{\"dashboard\": $DASHBOARD}" > "$TEMP_FILE"

#           curl -X POST http://127.0.0.1:3000/api/dashboards/db \
#                -H "Content-Type: application/json" \
#                -u grafana:grafanapwd \
#                -d @"$TEMP_FILE"

#           rm "$TEMP_FILE"
#      fi
# done


# TEST_DASHBOARD=$(cat "/var/lib/grafana/dashboards/test-dashboard.json")
# POSTGRES_DASHBOARD=$(cat "/var/lib/grafana/dashboards/postgres-dashboard.json")

# curl -X POST http://127.0.0.1:3000/api/dashboards/db \
#      -H "Content-Type: application/json" \
#      -u grafana:grafanapwd \
#      -d @- <<EOF
#      {
#      "dashboard": $TEST_DASHBOARD
#      }
#      EOF

# curl -X POST http://127.0.0.1:3000/api/dashboards/db \
#      -H "Content-Type: application/json" \
#      -u grafana:grafanapwd \
#      -d @- <<EOF
#      {
#      "dashboard": $POSTGRES_DASHBOARD
#      }
#      EOF


# # Leggi i file JSON e assegna il contenuto alle variabili
# TEST_DASHBOARD=$(cat "/var/lib/grafana/dashboards/test-dashboard.json")
# POSTGRES_DASHBOARD=$(cat "/var/lib/grafana/dashboards/postgres-dashboard.json")

# # Invia il dashboard di test
# curl -X POST http://127.0.0.1:3000/api/dashboards/db \
#      -H "Content-Type: application/json" \
#      -u grafana:grafanapwd \
#      -d "{\"dashboard\": $TEST_DASHBOARD}" \
#      -d "{\"overwrite\": true}"

# # Invia il dashboard PostgreSQL
# curl -X POST http://127.0.0.1:3000/api/dashboards/db \
#      -H "Content-Type: application/json" \
#      -u grafana:grafanapwd \
#      -d "{\"dashboard\": $POSTGRES_DASHBOARD}" \
#      -d "{\"overwrite\": true}"


DASHBOARDS_PATH="/var/lib/grafana/dashboards"
ENDPOINT="http://127.0.0.1:3000/api/dashboards/db"
AUTH="${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}"

for FILE in "$DASHBOARDS_PATH"/*.json; do
     DASHBOARD_JSON=$(cat "$FILE")
     FILE_NAME=$(basename "$FILE" .json)

     curl -X POST "$ENDPOINT" \
          -H "Content-Type: application/json" \
          -u "$AUTH" \
          -d "{\"dashboard\": $DASHBOARD_JSON, \"overwrite\": true}"
     sleep 1
done
