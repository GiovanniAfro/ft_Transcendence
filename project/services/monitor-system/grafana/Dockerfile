FROM bitnami/grafana:10.4.8

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY tools/ /entrypoint/
COPY conf/grafana.ini /opt/bitnami/grafana/conf/
COPY conf/dashboards/ /opt/bitnami/grafana/conf/provisioning/dashboards/
