#!/bin/bash

set -e

# Defines --------------------------------------------------------------------->
WHITE_B='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create Setup Container ------------------------------------------------------>








# Initialize Vault ------------------------------------------------------------>
## Get Unseal Keys and Root Token -------------------------------------------->>
keys=$(docker exec hashicorp-vault vault operator init)
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

## Unseal Vault -------------------------------------------------------------->>
docker exec hashicorp-vault vault operator unseal $key1 > /dev/null 2>&1
docker exec hashicorp-vault vault operator unseal $key2 > /dev/null 2>&1
docker exec hashicorp-vault vault operator unseal $key3 > /dev/null 2>&1
echo -e "\n$BLUE[+] The vault has been unsealed"

# Import Secrets -------------------------------------------------------------->
# Enable KV Secrets Engine --------------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault secrets enable -path=secret kv >/dev/null 2>&1

echo -e "\n$BLUE[+] Enabled the kv secrets engine at:$WHITE_B secret/"

# Put secrets to Vault ------------------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token -i hashicorp-vault \
	vault kv put secret/app - < secrets/env/app.json > /dev/null

echo -e "\n$BLUE[+] Added app secrets to vault at $WHITE_B/secret/app"

docker exec -e VAULT_TOKEN=$root_token -i hashicorp-vault \
	vault kv put secret/log-system - < secrets/env/log-system.json > /dev/null

echo -e "\n$BLUE[+] Added log-system secrets to vault at $WHITE_B/secret/log-system"

# Create policy -------------------------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault policy write app-policy \
	/bitnami/vault/config/app-policy.hcl > /dev/null

echo -e "\n$BLUE[+] Uploaded policy:$WHITE_B app-policy"

docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault policy write log-system-policy \
	/bitnami/vault/config/log-system-policy.hcl > /dev/null

echo -e "\n$BLUE[+] Uploaded policy:$WHITE_B log-system-policy"

# Create tokens to access to secrets ----------------------------------------->>
app_token=$(docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault token create -policy="app-policy" -format=json \
	| jq -r .auth.client_token)

echo -e "\n$BLUE[+] Created token with access to $WHITE_B/secret/app$BLUE:\n    $WHITE_B$app_token"

logsystem_token=$(docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault token create -policy="log-system-policy" -format=json \
	| jq -r .auth.client_token)

echo -e "\n$BLUE[+] Created token with access to $WHITE_B/secret/log-system$BLUE:\n    $WHITE_B$logsystem_token${NC}"

# Generate Root CA ------------------------------------------------------------>
# Enable PKI Engine for Root CA Certificate ---------------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault secrets enable -path=pki pki > /dev/null

docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault secrets tune -max-lease-ttl=87600h pki > /dev/null

echo -e "\n$BLUE[+] Enabled the pki secrets engine for root CA at:$WHITE_B pki/"

# Generate Root CA Certificate ----------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write -field=certificate pki/root/generate/internal \
	common_name="ft-transcendence.42" issuer_name="root-2024" ttl=87600h \
	> /dev/null

echo -e "\n$BLUE[+] Generated root CA certificate"

# Create a Role for the Root CA ---------------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write pki/roles/2024-servers allow_any_name=true > /dev/null

echo -e "\n$BLUE[+] Created a role for the root CA"

# Set Endpoint for CA and CRL ------------------------------------------------>>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write pki/config/urls \
	issuing_certificates="https://10.0.4.1:8200/v1/pki/ca" \
	crl_distribution_points="https://10.0.4.1:8200/v1/pki/crl" > /dev/null

echo -e "\n$BLUE[+] Configured endpoints for CA certificates:\n \
   - crl_distribution_points:$WHITE_B https://10.0.4.1:8200/v1/pki/crl$BLUE\n \
   - issuing_certificates:$WHITE_B    https://10.0.4.1:8200/v1/pki/ca"

# Generate Intermediate CA ---------------------------------------------------->
# Enable PKI Engine for Intermediate CA Certificate -------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault secrets enable -path=pki_int pki > /dev/null

docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault secrets tune -max-lease-ttl=43800h pki_int > /dev/null

echo -e "\n$BLUE[+] Enabled the pki secrets engine for intermediate CA at:$WHITE_B pki_int/"

# Generate CSR for Intermediate CA Certificate ------------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write -format=json pki_int/intermediate/generate/internal \
	common_name="ft-transcendence.42 Intermediate Authority" \
	issuer_name="ft-transcendence-42-intermediate" \
	| jq -r '.data.csr' > /tmp/pki_intermediate.csr

docker cp /tmp/pki_intermediate.csr hashicorp-vault:/tmp/pki_intermediate.csr > /dev/null
rm -rf /tmp/pki_intermediate.csr
echo -e "\n$BLUE[+] Generated CSR for intermediate CA certificate"

# Sign the Intermediate Certificate with the Root CA ------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write -format=json pki/root/sign-intermediate \
	issuer_ref="root-2024" \
	csr=@/tmp/pki_intermediate.csr \
	format=pem_bundle ttl="43800h" \
	| jq -r '.data.certificate' > /tmp/intermediate.cert.pem

docker cp /tmp/intermediate.cert.pem hashicorp-vault:/tmp/intermediate.cert.pem > /dev/null
rm -rf /tmp/intermediate.cert.pem
echo -e "\n$BLUE[+] Signed intermediate CA with root CA private key"

# Set Endpoint for CA and CRL ------------------------------------------------>>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write pki_int/config/urls \
	issuing_certificates="https://10.0.4.1:8200/v1/pki_int/ca" \
	crl_distribution_points="https://10.0.4.1:8200/v1/pki_int/crl" > /dev/null

echo -e "\n$BLUE[+] Configured endpoints for CA certificates:\n \
   - crl_distribution_points:$WHITE_B https://10.0.4.1:8200/v1/pki_int/crl$BLUE\n \
   - issuing_certificates:$WHITE_B    https://10.0.4.1:8200/v1/pki_int/ca"

# Import signed Intermediate CA Certificate into vault ------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write pki_int/intermediate/set-signed certificate=@/tmp/intermediate.cert.pem > /dev/null

echo -e "\n$BLUE[+] Import signed intermediate CA certificate"

# Create a Role for the Intermediate CA -------------------------------------->>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write pki_int/roles/ft-transcendence-42 \
	allowed_domains="ft-transcendence.42" \
	allow_subdomains=true \
	max_ttl="720h"

echo -e "\n$BLUE[+] Created a role for the intermediate CA"

# Create Certificates for Containers ------------------------------------------>
# Create Certificates for hashicorp-vault ------------------------------------>>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write -format=json pki_int/issue/ft-transcendence-42 \
	common_name="vault.ft-transcendence.42" ip_sans="10.0.4.1" ttl="24h" > /tmp/vault-cert.json

jq -r '.data.certificate' /tmp/vault-cert.json > /tmp/vault.crt
jq -r '.data.private_key' /tmp/vault-cert.json > /tmp/vault.key
docker cp /tmp/vault.crt hashicorp-vault:/bitnami/vault/config/vault.crt > /dev/null
docker cp /tmp/vault.key hashicorp-vault:/bitnami/vault/config/vault.key > /dev/null
docker cp ./requirements/vault/hashicorp-vault/conf/vault-tls.json hashicorp-vault:/bitnami/vault/config/vault.json > /dev/null
# rm -rf /tmp/vault-cert.json && rm -rf /tmp/vault.crt && rm -rf /tmp/vault.key
echo -e "\n$BLUE[+] Created certificates for hashicorp-vault"







# Put tokens to .env ---------------------------------------------------------->
echo -e "APP_TOKEN=$app_token" >> .env
echo -e "LOG_SYSTEM_TOKEN=$logsystem_token" >> .env

# Restart Hashicorp-Vault ----------------------------------------------------->
# docker restart hashicorp-vault > /dev/null
# echo -e "\n$BLUE[+] Restarting Hashicorp-Vault"

# # Unseal Vault ---------------------------------------------------------------->
# docker exec -e VAULT_ADDR=https://10.0.4.1:8200 hashicorp-vault \
# 	vault operator unseal $key1
# docker exec -e VAULT_ADDR=https://10.0.4.1:8200 hashicorp-vault \
# 	vault operator unseal $key2
# docker exec -e VAULT_ADDR=https://10.0.4.1:8200 hashicorp-vault \
# 	vault operator unseal $key3
# echo -e "\n$BLUE[+] The vault has been unsealed"
