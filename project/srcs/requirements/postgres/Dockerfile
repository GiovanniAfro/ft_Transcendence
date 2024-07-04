FROM postgres:16-bookworm

COPY tools/add_remote_host.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/add_remote_host.sh
