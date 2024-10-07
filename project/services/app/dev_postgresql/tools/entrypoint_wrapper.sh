#!/usr/bin/bash

set -e

# psql \
# 	-U "$POSTGRESQL_USERNAME" \
# 	-d "$POSTGRESQL_DATABASE" \
# 	-c "INSERT INTO accounts_customuser (\
# 		username, password, email, is_active, date_joined) VALUES (\
# 		'test', 'test', 'test@test.it', TRUE, NOW());"

exec $0 $@ 
