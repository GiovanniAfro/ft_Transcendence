#!/usr/bin/env bash

set -xe  # Abilita il debug

echo "Starting entrypoint wrapper..."

TEST=test

# Run EntryPoint -------------------------------------------------------------->
POSTGRES_PASSWORD=psqlpwd POSTGRES_USER=postgres POSTGRES_DB=$TEST /opt/bitnami/scripts/postgresql/entrypoint.sh /opt/bitnami/scripts/postgresql/run.sh
