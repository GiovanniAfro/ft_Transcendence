#!/usr/bin/bash

set -ex

# Get Certs and Secrets from Vault -------------------------------------------->
certs=$(curl -k -H "X-Vault-Token: $PYTHON_VAULT_TOKEN" -X POST -d '{
		"common_name": "python.ft-transcendence.42",
		"ip_sans": "10.0.1.1",
		"ttl": "24h"
	}' https://10.0.0.1:8200/v1/pki_int/issue/python)

echo "$certs" | jq -r '.data.certificate' \
	> /opt/bitnami/python/conf/python.crt
echo "$certs" | jq -r '.data.private_key' \
	> /opt/bitnami/python/conf/python.key
echo "$certs" | jq -r '.data.issuing_ca' \
	> /opt/bitnami/python/conf/ca.crt
echo "$certs" | jq -r '.data.ca_chain[]' \
	> /opt/bitnami/python/conf/ca_chain.crt

env=$(curl -k -H "X-Vault-Token: ${PYTHON_VAULT_TOKEN}" \
	-X GET https://10.0.0.1:8200/v1/secret/python)

# Run EntryPoint in Background ------------------------------------------------>
DB_HOST=$(echo "$env" | jq -r '.data.DB_HOST') \
DB_PORT=$(echo "$env" | jq -r '.data.DB_PORT') \
DB_NAME=$(echo "$env" | jq -r '.data.DB_NAME') \
DB_USER=$(echo "$env" | jq -r '.data.DB_USER') \
DB_PASSWORD=$(echo "$env" | jq -r '.data.DB_PASSWORD') \
python

# # Check Postgresql Server ----------------------------------------------------->
# apt-get update -qq
# apt-get install -y -qq netcat-openbsd

# SUCCESS_MSG="Connection to ${DB_HOST} ${DB_PORT} port [tcp/postgresql] succeeded!"

# while ! [[ "$OUTPUT" == *"$SUCCESS_MSG"* ]]; do
#     OUTPUT=$(nc -zv ${DB_HOST} ${DB_PORT} 2>&1)
#     if [[ "$OUTPUT" == *"$SUCCESS_MSG"* ]]; then
#         echo "$SUCCESS_MSG"
#     else
#         echo "Connection to ${DB_HOST} ${DB_PORT} port [tcp/postgresql] failed. Retry ..."
#     fi
#     sleep 1
# done

# apt-get remove --purge -y -qq netcat-openbsd
# apt-get clean -qq
# rm -rf var/lib/apt/lists/*

# # Start Django server --------------------------------------------------------->

# python ft_transcendence/manage.py makemigrations
# python ft_transcendence/manage.py migrate
# # python ft_transcendence/manage.py shell <<EOF
# # from django.contrib.auth.models import User
# # username = "${DJANGO_ADMIN_USER}"
# # email = ""
# # password = "${DJANGO_ADMIN_PASS}"
# # if not User.objects.filter(username=username).exists():
# #     User.objects.create_superuser(username=username, email=email, password=password)
# # EOF
# python ft_transcendence/manage.py collectstatic --noinput
# python ft_transcendence/manage.py runserver 10.0.1.1:8000

# # Wait for the Main Process --------------------------------------------------->
# wait
