#!/usr/bin/env bash

set -e

# Generate TLS Certificates --------------------------------------------------->
# mkdir -p /bitnami/vault/certs/ && cd /bitnami/vault/certs/
# openssl genpkey -algorithm RSA -out server-key.pem
# openssl req -new -key server-key.pem -out server.csr
# openssl x509 -req -days 365 -in server.csr -signkey server-key.pem -out server-cert.pem

# Run EntryPoint -------------------------------------------------------------->
vault server -config=/bitnami/vault/config/vault.json
