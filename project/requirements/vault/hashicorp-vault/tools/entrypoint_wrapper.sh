#!/usr/bin/env bash

set -e

# Run EntryPoint -------------------------------------------------------------->
vault server -config=/bitnami/vault/config/vault.json
