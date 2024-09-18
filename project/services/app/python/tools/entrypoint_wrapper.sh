#!/usr/bin/bash

set -ex

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -k -H "X-Vault-Token: $PYTHON_VAULT_TOKEN" -X POST -d '{
		"common_name": "python.ft-transcendence.42",
		"ip_sans": "10.0.1.1",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/python)

echo "$certs" | jq -r '.data.certificate' \
	> /tmp/python.crt
echo "$certs" | jq -r '.data.private_key' \
	> /tmp/python.key
echo "$certs" | jq -r '.data.issuing_ca' \
	> /tmp/ca.crt
echo "$certs" | jq -r '.data.ca_chain[]' \
	> /tmp/ca_chain.crt

env=$(curl -k -H "X-Vault-Token: ${PYTHON_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/python)

db_host=$(echo "$env" | jq -r '.data.DB_HOST')
db_port=$(echo "$env" | jq -r '.data.DB_PORT')
db_name=$(echo "$env" | jq -r '.data.DB_NAME')
db_user=$(echo "$env" | jq -r '.data.DB_USER')
db_password=$(echo "$env" | jq -r '.data.DB_PASSWORD')

export DB_HOST=$db_host
export DB_PORT=$db_port
export DB_NAME=$db_name
export DB_USER=$db_user
export DB_PASSWORD=$db_password

# Waiting for the availability of Postgresql ---------------------------------->
success_msg="Connection to $db_host $db_port port [tcp/*] succeeded!"

while true; do
    out=$(nc -zv $db_host $db_port 2>&1)
    if [[ "$out" == *"$success_msg"* ]]; then
        echo "$success_msg"
		break
    else
        echo "Connection to $db_host $db_port port [tcp/*] failed. Retry ..."
    fi
    sleep 1
done

# Start Django server --------------------------------------------------------->
python pong_project/manage.py makemigrations
python pong_project/manage.py migrate
python pong_project/manage.py collectstatic --noinput
python pong_project/manage.py runserver 10.0.1.1:8000
