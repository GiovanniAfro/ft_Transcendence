FROM bitnami/prometheus:2.53.1-debian-12-r0

COPY conf/prometheus.yml /opt/bitnami/prometheus/conf/
COPY conf/alert.rules.yml /opt/bitnami/prometheus/conf/

CMD ["--config.file=/opt/bitnami/prometheus/conf/prometheus.yml", \
	"--storage.tsdb.retention.time=30d"]
