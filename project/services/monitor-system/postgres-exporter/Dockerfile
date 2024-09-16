FROM bitnami/postgres-exporter:0.15.0

USER root

RUN apt-get update && apt-get install -y curl jq && \
	mkdir -p /opt/bitnami/postgres-exporter/tls && \
	chown -R 1001:1001 /opt/bitnami/postgres-exporter/tls 

USER 1001

COPY tools/ /entrypoint/
# COPY conf/ /opt/bitnami/postgres-exporter/
