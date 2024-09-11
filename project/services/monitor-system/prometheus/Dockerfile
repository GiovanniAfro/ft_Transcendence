FROM bitnami/prometheus:2.54.1

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY tools/ /entrypoint/
COPY conf/ /opt/bitnami/prometheus/conf/

# CMD ["--config.file=/opt/bitnami/prometheus/conf/prometheus.yml", "--web.config.file=/opt/bitnami/prometheus/conf/web.yml, --storage.tsdb.retention.time=30d"]
