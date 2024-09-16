FROM bitnami/nginx-exporter:1.3.0

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY tools/ /entrypoint/
