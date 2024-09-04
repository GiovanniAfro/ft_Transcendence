#!/bin/bash

set -eu

TYPE=host        
DATABASE=${POSTGRESQL_DATABASE}
USER=${POSTGRESQL_USERNAME}
ADDRESS=10.0.1.1/32      
METHOD=trust       
PG_HBA_CONF="/opt/bitnami/postgresql/conf/pg_hba.conf"

echo "$TYPE $DATABASE $USER $ADDRESS $METHOD" >> "$PG_HBA_CONF"
