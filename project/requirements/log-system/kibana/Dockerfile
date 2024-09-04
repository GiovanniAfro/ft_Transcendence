FROM bitnami/kibana:8.15.0

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY tools/ /entrypoint/
