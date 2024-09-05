#!/bin/bash

set -e

# Defines --------------------------------------------------------------------->
WHITE_BOLD='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initialize Vault ------------------------------------------------------------>
keys=$(docker exec hashicorp-vault vault operator init)
key1=$(echo "$keys" | grep 'Unseal Key 1:' | awk '{print $4}')
key2=$(echo "$keys" | grep 'Unseal Key 2:' | awk '{print $4}')
key3=$(echo "$keys" | grep 'Unseal Key 3:' | awk '{print $4}')
key4=$(echo "$keys" | grep 'Unseal Key 4:' | awk '{print $4}')
key5=$(echo "$keys" | grep 'Unseal Key 5:' | awk '{print $4}')
root_token=$(echo "$keys" | grep 'Initial Root Token:' | awk '{print $4}')

echo -e "\n$BLUE [+] Vault initialized. Here are the keys and the root token:"
echo -e "$BLUE    UNSEAL KEY 1: $WHITE_BOLD$key1"
echo -e "$BLUE    UNSEAL KEY 2: $WHITE_BOLD$key2"
echo -e "$BLUE    UNSEAL KEY 3: $WHITE_BOLD$key3"
echo -e "$BLUE    UNSEAL KEY 4: $WHITE_BOLD$key4"
echo -e "$BLUE    UNSEAL KEY 5: $WHITE_BOLD$key5"
echo -e "$BLUE    ROOT TOKEN:   $WHITE_BOLD$root_token"

# Unseal Vault ---------------------------------------------------------------->
docker exec hashicorp-vault vault operator unseal $key1 > /dev/null 2>&1
docker exec hashicorp-vault vault operator unseal $key2 > /dev/null 2>&1
docker exec hashicorp-vault vault operator unseal $key3 > /dev/null 2>&1
echo -e "\n$BLUE[+] The vault has been unsealed"

# Enable KV Secrets Engine ---------------------------------------------------->
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault secrets enable -path=secret kv >/dev/null 2>&1
echo -e "\n$BLUE[+] Enabled the kv secrets engine at:$WHITE_BOLD secret/"

# Put secrets to Vault -------------------------------------------------------->
docker exec -e VAULT_TOKEN=$root_token -i hashicorp-vault \
	vault kv put secret/app - < secrets/env/app.json > /dev/null
echo -e "\n$BLUE[+] Added app secrets to vault at $WHITE_BOLD/secret/app"

docker exec -e VAULT_TOKEN=$root_token -i hashicorp-vault \
	vault kv put secret/log-system - < secrets/env/log-system.json > /dev/null
echo -e "\n$BLUE[+] Added log-system secrets to vault at $WHITE_BOLD/secret/log-system"

# Create policy --------------------------------------------------------------->
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault policy write app-policy \
	/bitnami/vault/config/app-policy.hcl > /dev/null
echo -e "\n$BLUE[+] Uploaded policy:$WHITE_BOLD app-policy"

docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault policy write log-system-policy \
	/bitnami/vault/config/log-system-policy.hcl > /dev/null
echo -e "\n$BLUE[+] Uploaded policy:$WHITE_BOLD log-system-policy"

# Create tokens to access to secrets ------------------------------------------>
app_token=$(docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault token create -policy="app-policy" -format=json \
	| jq -r .auth.client_token)
echo -e "\n$BLUE[+] Created token with access to $WHITE_BOLD/secret/app$BLUE:\n    $WHITE_BOLD$app_token"

logsystem_token=$(docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault token create -policy="log-system-policy" -format=json \
	| jq -r .auth.client_token)
echo -e "\n$BLUE[+] Created token with access to $WHITE_BOLD/secret/log-system$BLUE:\n    $WHITE_BOLD$logsystem_token${NC}"

# Enable PKI Engine ----------------------------------------------------------->
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault secrets enable -path=certs pki > /dev/null
# docker exec -e VAULT_TOKEN=$root_token hashicorp-vault vault secrets tune -max-lease-ttl=87600h certs 
echo -e "\n$BLUE[+] Enabled the pki secrets engine at:$WHITE_BOLD certs/" > /dev/null

# Set endpoint for CA certs --------------------------------------------------->
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write certs/config/urls \
	issuing_certificates="http://10.0.4.1:8200/v1/certs/ca" \
	crl_distribution_points="http://10.0.4.1:8200/v1/certs/crl" > /dev/null
echo -e "\n$BLUE[+] Configured endpoints for CA certificates:\n    crl_distribution_points:$WHITE_BOLD http://10.0.4.1:8200/v1/certs/crl$BLUE\n    issuing_certificates:$WHITE_BOLD    http://10.0.4.1:8200/v1/certs/ca"

# Generate Root CA certificate ------------------------------------------------>
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write certs/root/generate/internal \
	common_name="vault-root-ca" ttl=87600h > /dev/null
echo -e "\n$BLUE[+] Generated Root CA certificate"

# Generate CSR for Intermediate CA certificate -------------------------------->
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write -format=json certs/intermediate/generate/internal \
    common_name="vault-intermediate-ca" \
    ttl=768h
echo -e "\n$BLUE[+] Generated CSR for Intermediate CA certificate"

# Signing Intermediate CA with Root CA ---------------------------------------->
docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
	vault write -format=json certs/root/sign-intermediate \
    csr="$(docker exec -e VAULT_TOKEN=$root_token hashicorp-vault \
		   vault write -format=json certs/intermediate/generate/internal \
		   common_name="vault-intermediate-ca" ttl=768h | jq -r '.data.csr'\
	)" \
    format=pem_bundle \
    ttl=768h
echo -e "\n$BLUE[+] Signed Intermediate CA with Root CA"

# Set Intermediate CA certificate --------------------------------------------->
# TODO \\






# Put tokens to .env ---------------------------------------------------------->
echo -e "APP_TOKEN=$app_token" >> .env
echo -e "LOG_SYSTEM_TOKEN=$logsystem_token" >> .env

# # Restart Hashicorp-Vault ----------------------------------------------------->
# docker restart hashicorp-vault
# echo -e "\n$BLUE[+] Restart Hashicorp-Vault"

# # Unseal Vault ---------------------------------------------------------------->
# docker exec hashicorp-vault vault operator unseal $key1 > /dev/null 2>&1
# docker exec hashicorp-vault vault operator unseal $key2 > /dev/null 2>&1
# docker exec hashicorp-vault vault operator unseal $key3 > /dev/null 2>&1
# echo -e "\n$BLUE[+] The vault has been unsealed"
