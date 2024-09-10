#!/bin/bash

set -e

# Defines --------------------------------------------------------------------->
WHITE_B='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create Setup Container ------------------------------------------------------>
# Create TMP Directory ------------------------------------------------------->>
mkdir -p setup/.tmp

# Create Network ------------------------------------------------------------->>
docker network inspect secrets >/dev/null 2>&1 || docker network create \
	--driver bridge \
	--subnet 10.0.0.0/24 \
	--gateway 10.0.0.254 \
	secrets > /dev/null

# Create Volume -------------------------------------------------------------->>
docker volume create vault > /dev/null

# Create Container ----------------------------------------------------------->>
docker create \
	--name vault-setup \
	--env VAULT_ADDR=http://10.0.0.1:8200 \
	--cap-add IPC_LOCK \
	--network secrets \
	--ip 10.0.0.1 \
	-p 8200:8200 \
	--mount source=vault,target=/bitnami/vault \
	--entrypoint "vault" \
	bitnami/vault:1.17.5 server -config=/tmp/setup_vault.json > /dev/null 2>&1

# Copy Configfile ------------------------------------------------------------>>
docker cp setup/setup_vault.json vault-setup:/tmp/setup_vault.json > /dev/null

# Start Container ------------------------------------------------------------>>
docker start vault-setup > /dev/null

# Change Ownership of Volume ------------------------------------------------->>
docker exec --user=root vault-setup chown -R vault:root /bitnami/vault \
	> /dev/null

# Install Utilities ---------------------------------------------------------->>
docker exec --user=root vault-setup apt-get update > /dev/null 2>&1 \
	&& apt-get install -y jq > /dev/null 2>&1

# Initialize Vault ------------------------------------------------------------>
# Get Unseal Keys and Root Token --------------------------------------------->>
keys=$(docker exec vault-setup vault operator init)
key1=$(echo "$keys" | grep 'Unseal Key 1:' | awk '{print $4}')
key2=$(echo "$keys" | grep 'Unseal Key 2:' | awk '{print $4}')
key3=$(echo "$keys" | grep 'Unseal Key 3:' | awk '{print $4}')
key4=$(echo "$keys" | grep 'Unseal Key 4:' | awk '{print $4}')
key5=$(echo "$keys" | grep 'Unseal Key 5:' | awk '{print $4}')
root_token=$(echo "$keys" | grep 'Initial Root Token:' | awk '{print $4}')

echo -e "\n$BLUE[+] Vault initialized. Here are the keys and the root token:"
echo -e "$BLUE    - UNSEAL KEY 1: $WHITE_B$key1"
echo -e "$BLUE    - UNSEAL KEY 2: $WHITE_B$key2"
echo -e "$BLUE    - UNSEAL KEY 3: $WHITE_B$key3"
echo -e "$BLUE    - UNSEAL KEY 4: $WHITE_B$key4"
echo -e "$BLUE    - UNSEAL KEY 5: $WHITE_B$key5"
echo -e "$BLUE    - ROOT TOKEN:   $WHITE_B$root_token"

# Unseal Vault --------------------------------------------------------------->>
docker exec vault-setup vault operator unseal $key1 > /dev/null 2>&1
docker exec vault-setup vault operator unseal $key2 > /dev/null 2>&1
docker exec vault-setup vault operator unseal $key3 > /dev/null 2>&1
echo -e "\n$BLUE[+] The vault has been unsealed"

# Generate Root CA ------------------------------------------------------------>
# Enable PKI Engine for Root CA Certificate ---------------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault secrets enable -path=pki pki > /dev/null

docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault secrets tune -max-lease-ttl=87600h pki > /dev/null

echo -e "\n$BLUE[+] Enabled the pki secrets engine for root CA at:$WHITE_B pki/"

# Generate Root CA Certificate ----------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write -field=certificate pki/root/generate/internal \
	common_name="ft-transcendence.42" issuer_name="root-2024" ttl=87600h \
	> /dev/null

echo -e "\n$BLUE[+] Generated root CA certificate"

# Create a Role for the Root CA ---------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write pki/roles/2024-servers allow_any_name=true > /dev/null

echo -e "\n$BLUE[+] Created a role for the root CA"

# Set Endpoint for CA and CRL ------------------------------------------------>>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write pki/config/urls \
	issuing_certificates="https://10.0.0.1:8200/v1/pki/ca" \
	crl_distribution_points="https://10.0.0.1:8200/v1/pki/crl" > /dev/null

echo -e "\n$BLUE[+] Configured endpoints for CA certificates:\n \
   - crl_distribution_points:$WHITE_B https://10.0.0.1:8200/v1/pki/crl$BLUE\n \
   - issuing_certificates:$WHITE_B    https://10.0.0.1:8200/v1/pki/ca"

# Generate Intermediate CA ---------------------------------------------------->
# Create TLS and Config Directories ------------------------------------------>>
docker exec vault-setup mkdir -p /bitnami/vault/tls
docker exec vault-setup mkdir -p /bitnami/vault/config

# Enable PKI Engine for Intermediate CA Certificate -------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault secrets enable -path=pki_int pki > /dev/null

docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault secrets tune -max-lease-ttl=43800h pki_int > /dev/null

echo -e "\n$BLUE[+] Enabled the pki secrets engine for intermediate CA at:$WHITE_B pki_int/"

# Generate CSR for Intermediate CA Certificate ------------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write -format=json pki_int/intermediate/generate/internal \
	common_name="ft-transcendence.42 Intermediate Authority" \
	issuer_name="ft-transcendence-42-intermediate" \
	| jq -r '.data.csr' > setup/.tmp/pki_intermediate.csr

docker cp setup/.tmp/pki_intermediate.csr \
	vault-setup:/tmp/pki_intermediate.csr > /dev/null

echo -e "\n$BLUE[+] Generated CSR for intermediate CA certificate"

# Sign the Intermediate Certificate with the Root CA ------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write -format=json pki/root/sign-intermediate \
	issuer_ref="root-2024" \
	csr=@/tmp/pki_intermediate.csr \
	format=pem_bundle ttl="43800h" \
	| jq -r '.data.certificate' > setup/.tmp/intermediate.cert.pem

docker cp setup/.tmp/intermediate.cert.pem \
	vault-setup:/bitnami/vault/tls/intermediate.cert.pem > /dev/null

echo -e "\n$BLUE[+] Signed intermediate CA with root CA private key"

# Set Endpoint for CA and CRL ------------------------------------------------>>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write pki_int/config/urls \
	issuing_certificates="https://10.0.0.1:8200/v1/pki_int/ca" \
	crl_distribution_points="https://10.0.0.1:8200/v1/pki_int/crl" > /dev/null

echo -e "\n$BLUE[+] Configured endpoints for CA certificates:\n \
   - crl_distribution_points:$WHITE_B https://10.0.0.1:8200/v1/pki_int/crl$BLUE\n \
   - issuing_certificates:$WHITE_B    https://10.0.0.1:8200/v1/pki_int/ca"

# Import signed Intermediate CA Certificate into vault ----------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write pki_int/intermediate/set-signed \
	certificate=@/bitnami/vault/tls/intermediate.cert.pem > /dev/null

echo -e "\n$BLUE[+] Import signed intermediate CA certificate"

# Create a Role for the Intermediate CA -------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write pki_int/roles/ft-transcendence-42 \
	allowed_domains="ft-transcendence.42" \
	allow_subdomains=true \
	max_ttl="720h" > /dev/null

echo -e "\n$BLUE[+] Created a role for the intermediate CA"

# Create TLS Certificates for vault ------------------------------------------>>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write -format=json pki_int/issue/ft-transcendence-42 \
	common_name="vault.ft-transcendence.42" ip_sans="10.0.0.1" ttl="24h"\
	> setup/.tmp/vault-cert.json

jq -r '.data.certificate' setup/.tmp/vault-cert.json > setup/.tmp/vault.crt
jq -r '.data.private_key' setup/.tmp/vault-cert.json > setup/.tmp/vault.key
docker cp setup/.tmp/vault.crt vault-setup:/bitnami/vault/tls/vault.crt > /dev/null
docker cp setup/.tmp/vault.key vault-setup:/bitnami/vault/tls/vault.key > /dev/null
echo -e "\n$BLUE[+] Created certificates for vault-setup"
docker cp services/secrets/vault/conf/vault.hcl \
	vault-setup:/bitnami/vault/config/vault.hcl > /dev/null

# # Create TLS Certificates for ELASTICSEARCH ---------------------------------->>
# docker exec -e VAULT_TOKEN=$root_token vault-setup \
# 	vault write pki_int/issue/ft-transcendence-42 \
# 	common_name="ELASTICSEARCH.ft-transcendence.42" ip_sans="10.0.2.1" ttl="24h"

# Import Secrets -------------------------------------------------------------->
# Enable KV Secrets Engine --------------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault secrets enable -path=secret kv >/dev/null 2>&1

echo -e "\n$BLUE[+] Enabled the kv secrets engine at:$WHITE_B secret/"

# Import Secrets to Vault ---------------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token -i vault-setup \
	vault kv put secret/django - <<< \
	$(jq -r '.django' ./.env.json) > /dev/null

docker exec -e VAULT_TOKEN=$root_token -i vault-setup \
	vault kv put secret/postgresql - <<< \
	$(jq -r '.postgresql' ./.env.json) > /dev/null

docker exec -e VAULT_TOKEN=$root_token -i vault-setup \
	vault kv put secret/elasticsearch - <<< \
	$(jq -r '.elasticsearch' ./.env.json) > /dev/null

docker exec -e VAULT_TOKEN=$root_token -i vault-setup \
	vault kv put secret/logstash - <<< \
	$(jq -r '.logstash' ./.env.json) > /dev/null

docker exec -e VAULT_TOKEN=$root_token -i vault-setup \
	vault kv put secret/kibana - <<< \
	$(jq -r '.kibana' ./.env.json) > /dev/null

echo -e "\n$BLUE[+] Import secrets to vault:\n\
    $BLUE- Add$WHITE_B django$BLUE secrets at $WHITE_B/secret/django\n\
    $BLUE- Add$WHITE_B postgresql$BLUE secrets at $WHITE_B/secret/postgresql\n\
    $BLUE- Add$WHITE_B elasticsearch$BLUE secrets at $WHITE_B/secret/elasticsearch\n\
    $BLUE- Add$WHITE_B logstash$BLUE secrets at $WHITE_B/secret/logstash\n\
    $BLUE- Add$WHITE_B kibana$BLUE secrets at $WHITE_B/secret/kibana"

# Authentication from Containers ---------------------------------------------->
# Create Roles --------------------------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write pki_int/roles/elasticsearch \
	allowed_domains="elasticsearch.ft-transcendence.42" \
	allow_subdomains=false allow_bare_domains=true \
	max_ttl="24h" > /dev/null

docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault write pki_int/roles/kibana \
	allowed_domains="kibana.ft-transcendence.42" \
	allow_subdomains=false allow_bare_domains=true \
	max_ttl="24h" > /dev/null

# Create Policies ------------------------------------------------------------>>
echo -e "\n$BLUE[+] Creating policies:"

for policy_file in services/secrets/vault/conf/*-policy.hcl; do
	file_name=$(basename "$policy_file")
	docker cp "$policy_file" vault-setup:/bitnami/vault/config/"$file_name" \
		> /dev/null
	docker exec -e VAULT_TOKEN=$root_token vault-setup \
		vault policy write ${file_name::-4} /bitnami/vault/config/$file_name \
		> /dev/null
	echo -e "$BLUE    -$WHITE_B ${file_name::-4}"   
done

# Create Tokens -------------------------------------------------------------->>
django_vault_token=$(docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault token create -policy="django-policy" -format=json \
	| jq -r .auth.client_token)

postgresql_vault_token=$(docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault token create -policy="postgresql-policy" -format=json \
	| jq -r .auth.client_token)

elasticsearch_vault_token=$(docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault token create -policy="elasticsearch-policy" -format=json \
	| jq -r .auth.client_token)

logstash_vault_token=$(docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault token create -policy="logstash-policy" -format=json \
	| jq -r .auth.client_token)

kibana_vault_token=$(docker exec -e VAULT_TOKEN=$root_token vault-setup \
	vault token create -policy="kibana-policy" -format=json \
	| jq -r .auth.client_token)

echo -e "\n$BLUE[+] Creating tokens with access to:\n\
    $WHITE_B/secret/django$BLUE: $WHITE_B$django_vault_token\n\
    $WHITE_B/secret/postgresql$BLUE: $WHITE_B$postgresql_vault_token\n\
    $WHITE_B/secret/elasticsearch$BLUE: $WHITE_B$elasticsearch_vault_token\n\
    $WHITE_B/secret/logstash$BLUE: $WHITE_B$logstash_vault_token\n\
    $WHITE_B/secret/kibana$BLUE: $WHITE_B$kibana_vault_token"

# Put tokens to .env --------------------------------------------------------->>
echo -e "DJANGO_VAULT_TOKEN=$django_vault_token" >> .env
echo -e "POSTGRESQL_VAULT_TOKEN=$postgresql_vault_token" >> .env
echo -e "ELASTICSEARCH_VAULT_TOKEN=$elasticsearch_vault_token" >> .env
echo -e "LOGSTASH_VAULT_TOKEN=$logstash_vault_token" >> .env
echo -e "KIBANA_VAULT_TOKEN=$kibana_vault_token" >> .env

# Cleanup --------------------------------------------------------------------->
docker container stop vault-setup > /dev/null 2>&1
docker container rm vault-setup > /dev/null 2>&1
docker network rm secrets > /dev/null 2>&1
rm -rf setup/.tmp

# Create Vault Container ------------------------------------------------------>
echo -e "\n$BLUE[+] Compose$WHITE_B SECRETS$BLUE profile ..."
docker compose -p "ft_transcendence" --profile secrets up -d >/dev/null 2>&1

# Unseal Vault ---------------------------------------------------------------->
docker exec vault vault operator unseal $key1 > /dev/null
docker exec vault vault operator unseal $key2 > /dev/null
docker exec vault vault operator unseal $key3 > /dev/null

echo -e "\n$BLUE[+] The vault has been unsealed"



# docker exec -e VAULT_TOKEN=hvs.qzgccwMYuBqLOAtMJ75zUipt vault \
# 	vault write pki_int/issue/ft-transcendence-42 \
# 	common_name="elasticsearch.ft-transcendence.42" ip_sans="10.0.2.1" ttl="24h"
