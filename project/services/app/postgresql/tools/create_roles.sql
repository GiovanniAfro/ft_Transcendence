CREATE ROLE 'postgresql.ft-transcendence.42' WITH LOGIN PASSWORD 'psqlpwd';
GRANT CONNECT ON DATABASE 'django_db' TO 'postgresql.ft-transcendence.42';
