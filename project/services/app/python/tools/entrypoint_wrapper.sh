#!/usr/bin/bash

set -x

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -k -H "X-Vault-Token: $PYTHON_VAULT_TOKEN" -X POST -d '{
		"common_name": "python.ft-transcendence.42",
		"ip_sans": "10.0.1.1",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/python)

mkdir -p /app/tls

echo "$certs" | jq -r '.data.certificate' > /app/tls/python.crt
echo "$certs" | jq -r '.data.private_key' > /app/tls/python.key
echo "$certs" | jq -r '.data.issuing_ca' > /app/tls/ca.crt
echo "$certs" | jq -r '.data.ca_chain[]' > /app/tls/ca_chain.crt

chmod 600 /app/tls/python.key

env=$(curl -k -H "X-Vault-Token: ${PYTHON_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/python)

export PYTHONPATH=$(echo "$env" | jq -r '.data.PYTHONPATH')
export DB_HOST=$(echo "$env" | jq -r '.data.DB_HOST')
export DB_PORT=$(echo "$env" | jq -r '.data.DB_PORT')
export DB_NAME=$(echo "$env" | jq -r '.data.DB_NAME')
export DB_USER=$(echo "$env" | jq -r '.data.DB_USER')
export DB_PASSWORD=$(echo "$env" | jq -r '.data.DB_PASSWORD')
export DB_TLS=$(echo "$env" | jq -r '.data.DB_TLS')
export TLS_CERT_FILE=$(echo "$env" | jq -r '.data.TLS_CERT_FILE')
export TLS_KEY_FILE=$(echo "$env" | jq -r '.data.TLS_KEY_FILE')
export TLS_CA_FILE=$(echo "$env" | jq -r '.data.TLS_CA_FILE')

# Waiting for the availability of Postgresql ---------------------------------->
success_msg="Connection to $DB_HOST $DB_PORT port [tcp/*] succeeded!"

while true; do
    out=$(nc -zv $DB_HOST $DB_PORT 2>&1)
    if [[ "$out" == *"$success_msg"* ]]; then
        echo "$success_msg"
		break
    else
        echo "Connection to $DB_HOST $DB_PORT port [tcp/*] failed. Retry ..."
    fi
    sleep 1
done

# Start Gunicorn server ------------------------------------------------------->
python pong_project/manage.py makemigrations
python pong_project/manage.py migrate
python pong_project/manage.py collectstatic --noinput
gunicorn --workers 3 --bind 0.0.0.0:8000 \
	--certfile=${TLS_CERT_FILE} \
	--ca-certs=${TLS_CA_FILE} \
	pong_project.wsgi:application
