#!/bin/bash

set -e



# Config ---------------------------------------------------------------------->
service postgresql start
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${POSTGRES_PASSWORD}';"
sudo -u postgres psql -c "CREATE USER ${POSTGRES_DB_USER} WITH PASSWORD '${POSTGRES_DB_PASS}';"
sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB_NAME} OWNER ${POSTGRES_DB_USER};"
# service postgresql stop

tail -f

exec "$@"

# postgres -D /var/lib/postgresql/data -c config_file=/etc/postgresql/15/main/postgresql.conf
