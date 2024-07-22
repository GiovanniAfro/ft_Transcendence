#!/bin/bash

set -e

TYPE=host        
DATABASE=all      
USER=all         
ADDRESS=10.0.1.1/32      
METHOD=trust       
PG_HBA_CONF="/var/lib/postgresql/data/pg_hba.conf"

echo "$TYPE $DATABASE $USER $ADDRESS $METHOD" >> "$PG_HBA_CONF"
