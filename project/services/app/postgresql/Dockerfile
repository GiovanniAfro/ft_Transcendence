FROM bitnami/postgresql:16

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY conf/ /bitnami/postgresql/conf/
COPY tools/entrypoint_wrapper.sh /entrypoint/
# COPY tools/create_roles.sql /docker-entrypoint-initdb.d/create_roles.sql
